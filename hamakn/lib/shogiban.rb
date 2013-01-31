# coding: utf-8

class Shogiban
  class OutOfRangeError < StandardError
  end

  def initialize(data)
    # 入力の改行は無視する、将棋盤なので横は9文字とする
    @size = 9
    lines = data.gsub("\n", "").scan(/.{#{@size}}/)
    @pixel = lines.map { |line| line.split(//) }
  end

  def at(h, w)
    raise OutOfRangeError if h < 0 || w < 0 || h >= @size || w >= @size
    @pixel[h][w]
  end

  def set(h, w, item)
    raise OutOfRangeError if h < 0 || w < 0 || h >= @size || w >= @size
    @pixel[h][w] = item
  end

  def inspect
    @pixel.inject("") { |result, line| result += line.join + "\n" }
  end
  alias :to_s :inspect

  # at(h, w)の駒を、+ph, +pwに動かしたShogiban Instanceを返す
  def koma_move(h, w, ph, pw)
    s = Shogiban.new(self.to_s)
    koma = s.at(h, w)
    s.set(h, w, "0")
    s.set(h + ph, w + pw, koma)
    s
  end

  # strの座標を返す
  def koma_pos(str)
    result = []
    @size.times do |h|
      @size.times do |w|
        result << {:h => h, :w => w} if at(h, w) == str
      end
    end
    result
  end
end
