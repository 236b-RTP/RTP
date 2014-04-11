require 'spec_helper'

describe TimeBlock do
	before(:all) do
		@startTime = DateTime.new(2014, 2, 3, 13)
		@endTime = DateTime.new(2014, 2, 3, 15)
	end
  it "can be initialized" do
  	@TimeBlock = TimeBlock.new(@startTime, @endTime, true, 4)
  end
  it "raises an error when not given DateTimes" do
  	expect {TimeBlock.new(1, @endTime, true, 4)}.to raise_error
  end
  it "returns true when it is a task" do
  	@Block = TimeBlock.new(@startTime,@endTime, true, 4)
  	@Block.is_task?.should == true
  end
  it "returns false when it is not a task" do
  	@Block = TimeBlock.new(@startTime, @endTime, false, 4)
  	@Block.is_task?.should == false
  end
end
