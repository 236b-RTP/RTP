require 'spec_helper'
require 'scheduler'

describe Scheduler do
	before(:each) do
		@start = DateTime.new(2012, 3, 15, 10)
		@end_time = DateTime.new(2012, 3, 15, 20)
		@user = double("User", :preference => double("preference", :end_time => @end_time, :start_time => @start, :profile_type => "early"))
	end
  it "can load events" do
  	
  	@sched = Scheduler.new(@user)
  end
end 
