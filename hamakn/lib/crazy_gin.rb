# coding: utf-8
require "rational"
require File.expand_path(File.join(__FILE__, "../shogiban"))

module CrazyGin
  # 銀を動かした回数や正解条件を満たすかを保持するオブジェクト
  class Status
    def initialize(args)
      @shogiban_id = args[:shogiban_id]
      @turn = args[:turn]
      @state_transition_probability = args[:state_transition_probability]
      @friends = args[:friends]
    end

    # 一手動かした結果を返す
    def next_statuses
      shogibans = GIN_MOVE_TO.map do |move|
        gin_move(move[:h], move[:w])
      end
      shogibans.map do |s|
        self.class.new({
          :shogiban_id => s.nil? ? nil : s.to_s,
          :turn => @turn - 1,
          :state_transition_probability => Rational(1, GIN_MOVE_TO.size),
          :friends => @friends
        })
      end
    end

    def gin_move(ph, pw)
      s = Shogiban.new(@shogiban_id)
      spos = s.koma_pos("S").first # Sは盤面上に1つしかない前提
      s.koma_move(spos[:h], spos[:w], ph, pw)
    rescue Shogiban::OutOfRangeError => e
      nil
    end

    def alive?
      return false unless @shogiban_id
      shogiban = Shogiban.new(@shogiban_id)
      shogiban.koma_pos("F").size < @friends ? false : true
    end

    def king?
      shogiban = Shogiban.new(@shogiban_id)
      shogiban.koma_pos("K").empty? ? true : false # Kも盤面上に1つしかない前提
    end

    @@probability_cache = {}
    def probability
      if @@probability_cache[status_id]
        # 1. キャッシュに値があればその値を使う
        return @state_transition_probability * @@probability_cache[status_id]
      end
      if self.alive? == false
        # 2. aliveがfalseであれば0
        p = 0
      elsif @turn == 0
        # 3. turnが0（動かし終わった）の場合、aliveがtrueで、kingもtrueであれば1、そうでなければ0
        if self.king?
          p = 1
        else
          p = 0
        end
      else
        # 4. 上記のいずれかでない場合、もう1回動かした結果を再帰で取得して合計する
        p = next_statuses.inject(0) do |memo, next_status|
          memo += next_status.probability
        end
      end
      @@probability_cache[status_id] = p
      return @state_transition_probability * p
    end

    def status_id
      "#{@turn}:#{@shogiban_id}"
    end
  end
end

module CrazyGin
  GIN_MOVE_TO = [
    {:h => -1, :w => -1},
    {:h => -1, :w =>  0},
    {:h => -1, :w =>  1},
    {:h =>  1, :w => -1},
    {:h =>  1, :w =>  1},
  ]

  def self.init(args)
    @turn = args[:turn]
    @initial_shogiban = args[:initial_shogiban]
  end

  def self.solve
    raise if @turn.nil?
    raise if @initial_shogiban.nil?

    status = Status.new({
      :shogiban_id => @initial_shogiban.to_s,
      :turn => @turn,
      :state_transition_probability => Rational(1, 1),
      :friends => @initial_shogiban.koma_pos("F").size,
    })

    status.probability
  end
end
