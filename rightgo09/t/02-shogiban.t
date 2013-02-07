use strict;
use warnings;
use Test::More;
use CrazyGin;

my $shogiban = Shogiban->new('O', ' ', 'G', 'F');

subtest 'gin, ou' => sub {
  my $masu_ou  =  Masu->new({ height => 0, width => 0, koma => 'O', stash => 0 });
  my $masu_no  =  Masu->new({ height => 1, width => 0, koma => ' ', stash => 0 });
  my $masu_gin =  Masu->new({ height => 2, width => 0, koma => 'G', stash => 0 });
  my $masu_fu  =  Masu->new({ height => 3, width => 0, koma => 'F', stash => 0 });

  is_deeply [$shogiban->each_masu], [$masu_ou, $masu_no, $masu_gin, $masu_fu];
  is_deeply $shogiban->gin, $masu_gin;
  is_deeply $shogiban->ou, $masu_ou;
};

subtest 'routes_pattern' => sub {
  my $gin = $shogiban->gin;
  $gin->routes(1);
  $shogiban->routes_pattern;

  cmp_ok $shogiban->[0][0]->stash, '==', 0;
  cmp_ok $shogiban->[1][0]->stash, '==', 0;
  cmp_ok $shogiban->[2][0]->stash, '==', 0;
  cmp_ok $shogiban->[3][0]->stash, '==', 0;

  is $shogiban->[0][0]->routes, 0;
  is $shogiban->[1][0]->routes, 1;
  is $shogiban->[2][0]->routes, 0;
  is $shogiban->[3][0]->routes, 0;
};

done_testing;
