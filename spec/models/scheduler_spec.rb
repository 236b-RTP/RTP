require 'spec_helper'

describe Scheduler do
  let(:user) { create(:user) }
  let(:event_right_now) { create(:event, :start_date => DateTime.now, :end_date => DateTime.now + 2.hours,
                                 :task_event => create(:task_event, :user => user)) }
  let(:due_in_a_week) { create(:task, :start_date => DateTime.now, :due_date => DateTime.now + 7.days, :priority => 3,
                               :task_event => create(:task_event, :user => user)) }
  let(:due_in_two_days) { create(:task, :start_date => DateTime.now, :due_date => DateTime.now + 2.days, :priority => 3,
                                 :task_event => create(:task_event, :user => user)) }
  let(:due_in_five_days) { create(:task, :start_date => DateTime.now, :due_date => DateTime.now + 5.days, :priority => 3,
                                  :task_event => create(:task_event, :user => user)) }

  before(:each) do
    @start = DateTime.new(2014, 4, 29, 10, 0, 0)
    @end_time = DateTime.new(2014, 4, 29, 20, 0, 0)

    @default_tasks = [due_in_a_week, due_in_five_days, due_in_two_days]
  end

  it "can be initialized" do
    user.tasks << due_in_five_days
    user.tasks << due_in_two_days
    user.events << event_right_now
    expect{ Scheduler.new(user) }.to_not raise_error
  end

  context '#schedule' do
    it 'calls :schedule_spread if the users preference is to spread schedules' do
      user.preference = create(:preference)

      scheduler = Scheduler.new(user)
      expect(scheduler).to receive(:schedule_spread)

      scheduler.schedule
    end

    it 'calls :schedule_condensed if the user preference is to condense schedules' do
      user.preference = create(:condensed_preference)

      scheduler = Scheduler.new(user)
      expect(scheduler).to receive(:schedule_condensed)

      scheduler.schedule
    end
  end

  it "can load events" do
    scheduler = Scheduler.new(user)
    event2 = create(:event, :start_date => DateTime.now + 2.hours, :end_date => DateTime.now + 4.hours)
    scheduler.load_events([event_right_now, event2])
  end

  it "can schedule using normal scheduler" do
    @default_tasks.each do |task|
      user.tasks << task
    end
    scheduler = Scheduler.new(user)
    expect(scheduler.schedule_condensed[1]).to be_empty
  end

  it "can schedule using spread scheduler" do
    (0..6).each do
      user.tasks << create(:task, :start_date => DateTime.now, :due_date => DateTime.now + 5.days, :priority => 3,
                           :task_event => create(:task_event, :user => user))
    end
    Scheduler.new(user)
  end

  it "returns unschedulable tasks in normal scheduler" do
    (0..30).each do
      user.tasks << create(:task, :start_date => DateTime.now, :due_date => DateTime.now + 2.days, :priority => 3,
                           :task_event => create(:task_event, :user => user))
    end
    scheduler = Scheduler.new(user)
    expect(scheduler.schedule_condensed[1]).to_not be_empty
  end

  it "returns unschedulable tasks in spread scheduler" do
    (0..30).each do
      user.tasks << create(:task, :start_date => DateTime.now, :due_date => DateTime.now + 2.days, :priority => 3,
                           :task_event => create(:task_event, :user => user))
    end
    scheduler = Scheduler.new(user)
    expect(scheduler.schedule_spread).to_not be_empty
  end

  # it "can schedule tasks past sunday using normal schedule" do
  #   (0..50).each do
  #     user.tasks << create(:task, :start_date => DateTime.now, :due_date => DateTime.now + 7.days, :priority => 3,
  #                          :task_event => create(:task_event, :user => user))
  #   end
  #   scheduler = Scheduler.new(user)
  #   expect(scheduler.schedule_condensed[0][1].filled).to_not be_empty
  # end

  # it "can schedule tasks past sunday using spread schedule" do
  #   (0..25).each do
  #     user.tasks << create(:task, :start_date => DateTime.now, :due_date => DateTime.now + 7.days, :priority => 3,
  #                          :task_event => create(:task_event, :user => user))
  #   end
  #   scheduler = Scheduler.new(user)
  #   expect(scheduler.schedule_spread[0][1].filled).to_not be_empty
  # end

  it "schedules events at the end of the day for night-owls in normal schedule" do
    user.preference = create(:night_own_preference)

    (0..6).each do
      user.tasks << create(:task, :start_date => DateTime.now, :due_date => DateTime.now + 7.days, :priority => 3,
                           :task_event => create(:task_event, :user => user))
    end

    scheduler = Scheduler.new(user)
    arr = scheduler.schedule_condensed
  end
end