require 'spec_helper'
require 'scheduler'

describe Scheduler do
	before(:each) do
		@start = DateTime.new(2014, 4, 29, 10)
		@end_time = DateTime.new(2014, 4, 29, 20)
		@event_right_now = double("event_right_now", :start_date => DateTime.now, :end_date => DateTime.now + 2.hours, :completed? => false)
		@due_in_a_week = double("due_in_a_week", :start_date => DateTime.now, :created_at => DateTime.now - 2.days,
		 :duration => 60, :due_date => DateTime.now + 7.days, :priority => 3, :completed? => false)
		@due_in_two_days = double("due_in_two_days", :start_date => DateTime.now, :created_at => DateTime.now - 2.days,
		 :duration => 60, :due_date => DateTime.now + 2.days, :priority => 3, :completed? => false)
		@due_in_five_days = double("due_in_five_days", :start_date => DateTime.now, :created_at => DateTime.now - 2.days,
		 :duration => 60, :due_date => DateTime.now + 5.days, :priority => 3, :completed? => false)
		@user = double("User", :preference => double("preference", :end_time => @end_time, 
			:start_time => @start, :profile_type => "early"), :events => [], :tasks => [])
    @default_tasks = [@due_in_a_week, @due_in_five_days, @due_in_two_days]
	end
  it "can be initialized" do
  	user = @user
    user.tasks << @due_in_five_days
    user.tasks << @due_in_two_days
    user.events << @event_right_now
  	@sched = Scheduler.new(@user)
  end

  it "can load events" do
  	@sched = Scheduler.new(@user)
  	event2 = double("Event2",:start_date => DateTime.now + 2.hours, :end_date => DateTime.now + 4.hours)
  	@sched.load_events([@event_right_now, event2])
  end

  it "can schedule using normal scheduler" do
    user = @user
    @default_tasks.each do |task|
      user.tasks << task
    end
  	sched = Scheduler.new(user)
    sched.schedule[1].should be_empty
  end

  it "can schedule using spread scheduler" do
    user = @user
    (0..6).each do
      user.tasks << @due_in_five_days
    end
  	@sched = Scheduler.new(user)
  end
  it "returns unschedulable tasks in normal scheduler" do
    user = @user
    (0..30).each do
      user.tasks << @due_in_two_days
    end
    sched = Scheduler.new(user)
    sched.schedule[1].should_not be_empty
  end

  it "returns unschedulable tasks in spread scheduler" do
    user = @user
    (0..30).each do
      user.tasks << @due_in_two_days
    end
    sched = Scheduler.new(user)
    sched.schedule_spread.should_not be_empty
  end
  it "can schedule tasks past sunday using normal schedule" do
    user = @user
    (0..50).each do
      user.tasks << @due_in_a_week
    end
    sched = Scheduler.new(user)
    sched.schedule[0][1].filled.should_not be_empty
  end

  it "can schedule tasks past sunday using spread schedule" do
    user = @user
    (0..25).each do
      user.tasks << @due_in_a_week
    end
    sched = Scheduler.new(user)
    sched.schedule_spread[0][1].filled.should_not be_empty
  end

  it "schedules events at the end of the day for night-owls in normal schedule" do
    user = @user
    user = double("User", :preference => double("preference", :end_time => @end_time, 
      :start_time => @start, :profile_type => "late"), :events => [], :tasks => [])
    (0..6).each do
      user.tasks << @due_in_a_week
    end
    sched = Scheduler.new(user)
    arr = sched.schedule
  end
end