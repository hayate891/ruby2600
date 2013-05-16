require 'spec_helper'
include Ruby2600::Constants

describe Ruby2600::TIA do

  subject(:tia) do
    tia = Ruby2600::TIA.new
    tia.cpu = mock('cpu', :step => 2)
    tia
  end

  let(:write_to_WSYNC_on_6th_call) do
    Proc.new do

    end
  end

  describe '#scanline' do
    before do
      tia[COLUBK] = 0xBB
      tia[COLUPF] = 0xFF
    end

    context 'all-zeros playfield' do
      before { tia[PF0] = tia[PF1] = tia[PF2] = 0x00 }
      it 'should generate a fullscanline with background color' do
        tia.scanline.should == Array.new(160, 0xBB)
      end
    end

    context 'all-ones playfield' do
      before { tia[PF0] = tia[PF1] = tia[PF2] = 0xFF }
      it 'should generate a fullscanline with foreground color' do
        tia.scanline.should == Array.new(160, 0xFF)
      end
    end

    context 'pattern playfield' do
      before do
        tia[PF0] = 0b01000101
        tia[PF1] = 0b01001011
        tia[PF2] = 0b01001011
      end

      it 'should generate matching pattern' do
        tia.scanline.should == [0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xFF, 0xFF, 0xFF, 0xFF, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xFF, 0xFF, 0xFF, 0xFF, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xFF, 0xFF, 0xFF, 0xFF, 0xBB, 0xBB, 0xBB, 0xBB, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xBB, 0xBB, 0xBB, 0xBB, 0xFF, 0xFF, 0xFF, 0xFF, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xFF, 0xFF, 0xFF, 0xFF, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xFF, 0xFF, 0xFF, 0xFF, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xFF, 0xFF, 0xFF, 0xFF, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xFF, 0xFF, 0xFF, 0xFF, 0xBB, 0xBB, 0xBB, 0xBB, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xBB, 0xBB, 0xBB, 0xBB, 0xFF, 0xFF, 0xFF, 0xFF, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xBB, 0xFF, 0xFF, 0xFF, 0xFF, 0xBB, 0xBB, 0xBB, 0xBB]
      end
    end

    describe 'cpu integration' do
      before { tia[PF0] = tia[PF1] = tia[PF2] = rand(256) }

      def write_to_wsync_on_6th_call
        @step_counter ||= 0
        @step_counter += 1
        tia[WSYNC] = rand(256) if @step_counter == 6
        2
      end

      it 'should spend 76 CPU cycles generating a scanline' do
        tia.cpu.stub(:step).and_return(2)
        tia.cpu.should_receive(:step).exactly(76 / 2).times

        tia.scanline
      end

      it 'should account for variable instruction lenghts' do
        # The 11 stubbed values below add up to 48 cycles. To make 76, TIA should
        # call it 7 more times (since it will return the last one, 4).
        tia.cpu.stub(:step).and_return(2, 3, 4, 5, 6, 7, 6, 5, 4, 2, 4)
        tia.cpu.should_receive(:step).exactly(11 + 7).times

        tia.scanline
      end

      it "should account for multiple lines with unmatching instruction size" do
        # 76 / 3 will be a "split" instruction (25 1/3), but they should add up
        # back to 76 in the course of three lines
        tia.cpu.stub(:step).and_return(3)
        tia.cpu.should_receive(:step).exactly(76).times

        tia.scanline
        tia.scanline
        tia.scanline
      end

      it 'should stop calling the CPU if WSYNC is written to' do
        tia.cpu.stub(:step) { write_to_wsync_on_6th_call }
        tia.cpu.should_receive(:step).exactly(6).times

        tia.scanline
      end
    end
  end
end
