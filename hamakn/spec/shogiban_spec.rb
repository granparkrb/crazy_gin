$:.unshift("./lib")
require "rational"
require "shogiban"

describe Shogiban do
  context "Use data/quiz01.txt" do
    before do
      @ban = Shogiban.new(File.read("./data/quiz01.txt"))
    end

    describe "#at" do
      it { expect(@ban.at(0, 0)).to eq "0" }
      it { expect(@ban.at(0, 4)).to eq "K" }
      it { expect(@ban.at(4, 4)).to eq "S" }
      it { expect(@ban.at(4, 2)).to eq "F" }
      it { expect { @ban.at(-1, -1) }.to raise_error Shogiban::OutOfRangeError }
      it { expect { @ban.at(10, 10) }.to raise_error Shogiban::OutOfRangeError }
    end

    describe "#koma_move" do
      it { expect(@ban.koma_move(4, 4, -1, -1).at(3, 3)).to eq "S" }
      it { expect(@ban.koma_move(4, 4, -1,  0).at(3, 4)).to eq "S" }
      it { expect(@ban.koma_move(4, 4, -1,  1).at(3, 5)).to eq "S" }
      it { expect(@ban.koma_move(4, 4,  1, -1).at(5, 3)).to eq "S" }
      it { expect(@ban.koma_move(4, 4,  1,  1).at(5, 5)).to eq "S" }
    end

    describe "#koma_pos" do
      it { expect(@ban.koma_pos("S")).to have(1).items }
      it { expect(@ban.koma_pos("S").first).to eq({:h => 4, :w => 4}) }
      it { expect(@ban.koma_pos("F")).to have(19).items }
      it { expect(@ban.koma_pos("F").first).to eq({:h => 3, :w => 7}) }
    end
  end
end
