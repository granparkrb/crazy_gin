$:.unshift("./lib")
require "crazy_gin"

describe CrazyGin::Status do
  context "Use data/quiz01.txt" do
    before do
      @ban = Shogiban.new(File.read("./data/quiz01.txt"))
      @status = CrazyGin::Status.new({
        :shogiban_id => @ban.to_s,
        :turn => 0,
        :percent => Rational(1, 1),
        :alive => true,
        :friends => @ban.koma_pos("F").size
      })
    end

    describe "#move_s" do
      it { expect(@status.gin_move(-1, -1).koma_pos("S").first).to eq({:h => 3, :w => 3}) }
      it { expect(@status.gin_move(-1,  0).koma_pos("S").first).to eq({:h => 3, :w => 4}) }
      it { expect(@status.gin_move(-1,  1).koma_pos("S").first).to eq({:h => 3, :w => 5}) }
      it { expect(@status.gin_move( 1, -1).koma_pos("S").first).to eq({:h => 5, :w => 3}) }
      it { expect(@status.gin_move( 1,  1).koma_pos("S").first).to eq({:h => 5, :w => 5}) }
    end

    describe "#next_statuses" do
      it do
        # pending
        #@status.next_statuses.first
      end
    end
  end
end

describe CrazyGin do
  context "Use data/quiz02.txt" do
    context "turn = 0" do
      before do
        @ban = Shogiban.new(File.read("./data/quiz02.txt"))
        CrazyGin.init({:turn => 0, :initial_shogiban => @ban})
      end
      it { expect(CrazyGin.solve).to eq Rational(0, 1) }
    end
    context "turn = 1" do
      before do
        @ban = Shogiban.new(File.read("./data/quiz02.txt"))
        CrazyGin.init({:turn => 1, :initial_shogiban => @ban})
      end
      it { expect(CrazyGin.solve).to eq Rational(1, 5) }
    end
    context "turn = 2" do
      before do
        @ban = Shogiban.new(File.read("./data/quiz02.txt"))
        CrazyGin.init({:turn => 2, :initial_shogiban => @ban})
      end
      it { expect(CrazyGin.solve).to eq Rational(4, 25) }
    end
  end
end
