require 'spec_helper'
require 'scheduler'

describe Scheduler do
	before(:each) do
		@start = DateTime.new(2014, 3, 15, 10)
		@end_time = DateTime.new(2014, 3, 15, 20)
		@event1 = double("Event1", :start_date => DateTime.now, :end_date => DateTime.now + 2.hours)
		@task1 = double("Task1", :start_date => DateTime.now, :created_at => DateTime.now - 2.days,
		 :due_date => DateTime.now + 2.days, :priority => 3)
		@user = double("User", :preference => double("preference", :end_time => @end_time, 
			:start_time => @start, :profile_type => "early"), :events => [@event1], :tasks => [@task1])
	end
  it "can be initialized" do
  	
  	@sched = Scheduler.new(@user)
  end

  it "can load events" do
  	@sched = Scheduler.new(@user)
  	event2 = double("Event2",:start_date => DateTime.now + 2.hours, :end_date => DateTime.now + 4.hours)
  	@sched.load_events([@event1, event2])
  end
end 
