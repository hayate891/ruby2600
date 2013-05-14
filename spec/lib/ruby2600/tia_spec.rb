require 'spec_helper'

describe Ruby2600::Tia do

  subject(:tia) { Ruby2600::Tia.new }
  describe '#scanline' do
    before do
      tia.colupf = 0x12
      tia.colubk = 0x34
    end
    context 'all-zeros playfield' do
      before { tia.pf0 = tia.pf1 = tia.pf2 = 0x00 }
      it 'should generate a fullscanline with background color' do
        tia.scanline.should == Array.new(160, tia.colubk)
      end
    end

    context 'all-ones playfield' do
      before { tia.pf0 = tia.pf1 = tia.pf2 = 0xFF }
      it 'should generate a fullscanline with foreground color' do
        tia.scanline.should == Array.new(160, tia.colupf)
      end
    end

    # context 'pattern playfield' do
    #   before do
    #     tia.pf0 = 0b01000101
    #     tia.pf1 = 0b01001011
    #     tia.pf2 = 0b01001011
    #   end

    #   it 'should generate the expected pattern' do
    #     tia.scanline.should == [0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x12, 0x12, 0x12, 0x12, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x12, 0x12, 0x12, 0x12, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x12, 0x12, 0x12, 0x12, 0x34, 0x34, 0x34, 0x34, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x34, 0x34, 0x34, 0x34, 0x12, 0x12, 0x12, 0x12, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x12, 0x12, 0x12, 0x12, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x12, 0x12, 0x12, 0x12, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x12, 0x12, 0x12, 0x12, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x12, 0x12, 0x12, 0x12, 0x34, 0x34, 0x34, 0x34, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x12, 0x34, 0x34, 0x34, 0x34, 0x12, 0x12, 0x12, 0x12, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x34, 0x12, 0x12, 0x12, 0x12, 0x34, 0x34, 0x34, 0x34]
    #   end
    # end
  end
end
