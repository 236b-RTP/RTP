require 'spec_helper'

describe TimeBlock do
	before do
		@start_time = DateTime.new(2014, 2, 3, 13, 0, 0)
		@end_time = DateTime.new(2014, 2, 3, 15, 0, 0)
  end

  it "can be initialized" do
  	expect { TimeBlock.new(@start_time, @end_time, true, 4) }.to_not raise_error
  end

  context '#is_task?' do
    it "returns true when it is a task" do
      block = TimeBlock.new(@start_time, @end_time, true, 4)
      expect(block.is_task?).to be_true
    end

    it "returns false when it is not a task" do
      block = TimeBlock.new(@start_time, @end_time, false, 4)
      expect(block.is_task?).to be_false
    end
  end
end
