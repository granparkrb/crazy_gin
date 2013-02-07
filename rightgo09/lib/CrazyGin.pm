use strict;
use warnings;
use utf8;
use feature qw/ say state /;

package CrazyGin { # CrazyGinクラス
  use Path::Class qw/ file /; # Path::Classからfile関数をインポート
  use List::Util qw/ min /;   # List::Utilからmin関数をインポート

  # 定数（ただのレキシカル変数）
  my $TURN = 20;       # 銀将が動くターン数
  my $MOVE_PATTERN = 5;  # 銀将の動くパターン数

  # 定数（パッケージ変数なのでクラス外側からでも参照可）
  our $OU  = 'O'; # 王将
  our $GIN = 'G'; # 銀将
  our $FU  = 'F'; # 歩兵

  # 将棋盤オブジェクト使い回し用クラス変数（ただのレキシカル変数）
  my $shogiban;

  # 起動サブルーチン
  sub run {
    my ($class, $filepath) = @_; # (クラス名、データファイルパス)
    $shogiban = Shogiban->new(file($filepath)->slurp(chomp => 1)); # 将棋盤オブジェクト作成
    say $class->calculate_probability; # 確率計算
  }

  # 確率計算サブルーチン
  sub calculate_probability {
    my ($class) = @_; # (クラス名)
    # 最初に銀のマスのroutesに1をセットして基点にする
    $shogiban->gin->routes(1); # 1をセット

    # 銀から王将までのパターン数
    my %pattern_ou_from_gin; # { 王将を討ったターン数 => そのパターン数 }

    # まず銀将が動くターン数を動かして、王将を討つパターンだけ計算してしまう
    for my $i (1..$TURN) {
      $shogiban->routes_pattern;
      # 王将が討ち取られるターンだった場合
      if ($shogiban->ou->routes) {
        # ハッシュにターン数をキーにして討ち取るパターンを保存しておく
        $pattern_ou_from_gin{$i} = $shogiban->ou->routes;
      }
    }

    # 王将を討つターンを計算し終わったら一度盤面のルートパターン情報をクリアしておく
    $shogiban->stash_clear;
    $shogiban->stash_to_routes;

    # 王将を討つ最小ターン数を取り出す
    my $min_victory = min(keys(%pattern_ou_from_gin)); # List::Util::min()

    # 次は王将のマスのroutesに1をセットして基点にする
    $shogiban->ou->routes(1); # 1をセット

    # 王将を討ち取ったので名前を変える
    $shogiban->ou->koma('X'); # Xをセット

    # 銀将が王将から盤上を動き回るパターン数
    my %board_from_ou; # { 王将を討ったターン数 => 銀将が盤上に残っているパターン数 }
                       # キーが「銀将が動き回るターン数」ではないのは、関連づけを簡単にするため

    # 銀将が動けるターン数から王将を討ち取った最小数を引いた回数分移動パターンを計算する
    for my $i (1..($TURN-$min_victory)) {
      $shogiban->routes_pattern;
      # 同ループ内で動いたターン数と王将を討ち取ったターン数を足すと、
      # 銀将が動ける回数であれば
      if (exists $pattern_ou_from_gin{$TURN-$i}) { # キーは銀将が王将を討ち取ったターン数
        # 王将を討ち取ったターン数をキーにして、盤上に生きている銀将のパターン数を保存
        $board_from_ou{$TURN-$i} = $shogiban->sum_routes;
      }
    }

    my $all_routes = 0; # 最終パターン数(銀将が王将を討ち盤上に生きている)
    # 王将を討ったパターン数分ループさせて最終パターン数を足し込む
    for my $victory_turn (keys(%pattern_ou_from_gin)) {
      # 銀将が王将を討ったパターン x 王将の位置から盤上に生きているパターン
      $all_routes += $pattern_ou_from_gin{$victory_turn} * ($board_from_ou{$victory_turn} || 1); # || 1なのは動き回る最終ターンで王将を討ったときを想定
    }

    # 上で算出したパターン数 / 実際に取りうる全パターン
    return $all_routes/($MOVE_PATTERN**$TURN);
  }
}

package Shogiban { # 将棋盤クラス
  use List::Util qw/ first sum /; # List::Utilからfirst,sum関数をインポート

  # コンストラクタ
  sub new {
    my ($class, @lines) = @_; # クラス名、元データ
    my $board = []; # データ格納用無名配列
     my $i = 0; # 添字用
     for my $line (@lines) {
       $board->[$i] = []; # ２次元配列用無名配列
       my $j = 0; # 添字用
       for my $masu (split(//, $line)) {
         push @{$board->[$i]}, Masu->new({ # デリファレンスしつつpush
          height => $i,    # 外側ループが盤面縦(高さ)
          width  => $j,    # 内側ループが盤面横(幅)
          koma   => $masu, # マスの駒(銀将or王将or味方or空白)
          stash  => 0,     # ターン内ルート計算用
        });
        $j++;
      }
      $i++;
    }
    return bless $board, $class; # 配列リファレンスに神様の祝福をして返却
  }

  # 全マス取得用メソッド
  sub each_masu {
    my ($self) = @_;
    return map @$_, @$self; # 二次元配列展開
  }

  # 銀将取得メソッド
  sub gin {
    # stateで状態を保持
    return state $gin ||=
      first { $_->koma eq $CrazyGin::GIN } +shift->each_masu;
  }

  # 王将取得メソッド
  sub ou {
    # stateで状態を保持
    return state $ou ||=
      first { $_->koma eq $CrazyGin::OU } +shift->each_masu;
  }

  # 盤上の銀将が動き得るパターンを各マスで算出するメソッド
  sub routes_pattern {
    my ($self) = @_;

    # 各マスでループ
    for my $masu ($self->each_masu) {
      # 王将のマス($CrazyGin::OU)だけ除外
      # しかし王将討伐後は名前が変わるので王将鎮座のマスも有効になる
      next if $masu->koma eq $CrazyGin::OU;

      # 銀将が存在する可能性があるマスなら
      if ($masu->routes) {
        # 次に動き得るマスに当ルートパターン数を足し込む
        $self->stashing($masu, $masu->height-1, $masu->width-1); # 左上
        $self->stashing($masu, $masu->height-1, $masu->width+0); # 上
        $self->stashing($masu, $masu->height-1, $masu->width+1); # 右上
        $self->stashing($masu, $masu->height+1, $masu->width-1); # 左下
        $self->stashing($masu, $masu->height+1, $masu->width+1); # 右下
      }
    }

    # 上で足し込んだルートパターン数をstashからroutesにコピー
    $self->stash_to_routes;
    # 全マスのstashのクリア
    $self->stash_clear;
  }

  # 進攻するマスへのルートパターン数足し込みとstashへの保存
  sub stashing {
    my ($self, $masu, $h, $w) = @_;

    # ありえないマスへの進攻は許可しない。
    ## 配列の添字に負の値は使用可能だが、そうすると盤上の辺の逆サイドに出てしまう
    return if $h < 0 || $w < 0 || !$self->[$h][$w];

    # 進攻するマスが味方歩兵でなければ進攻可能
    if ($self->[$h][$w]->koma ne $CrazyGin::FU) {
      # 同一ターン内stashと進攻前のルートパターン数を足してstashに保存
      $self->[$h][$w]->stash($self->[$h][$w]->stash + $masu->routes);
    }
  }

  # ターン内に保存されたstashをroutesにコピーするメソッド
  sub stash_to_routes {
    $_->routes($_->stash) for +shift->each_masu;
  }

  # 全マスのstash領域をクリアするメソッド
  sub stash_clear {
    $_->stash(0) for +shift->each_masu;
  }

  # 全マスのroutesをクリアするメソッド
  sub route_clear {
    $_->routes(0) for +shift->each_masu;
  }

  # 盤上の全マスのroutesを合計するメソッド
  sub sum_routes {
    return sum map $_->routes, +shift->each_masu;
  }
}

package Masu {
  use base 'Class::Accessor::Fast';
  __PACKAGE__->mk_accessors(qw/ height width koma routes stash /);
}

1;
