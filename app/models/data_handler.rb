require 'time_utilities'

class DataHandler
  def initialize(user, task = nil)
    @main_calendar = Scheduler.new(user, task)
  end

  def run_schedule
    cal = @main_calendar.schedule
    @week = cal[0]
    @rejected = cal[1]
    @past_due = cal[2]
    #puts cal[0].to_s
    cal[0].each do |day|
      @tasks = day.filled.select{|task| task.is_task?}
      @tasks.each do |block|
        block.item.update(start_date: block.t[:begin], end_date: block.t[:end])
      end
    end
  end

  def run_schedule_spread
    cal = @main_calendar.schedule_spread
    @week = cal[0]
    @rejected = cal[1]
    @past_due = cal[2]
    #puts cal[0].to_s
    cal[0].each do |day|
      @tasks = day.filled.select{|task| task.is_task?}
      @tasks.each do |block|
        block.item.update(start_date: block.t[:begin], end_date: block.t[:end])
      end
    end
  end

  def handle_past_due
    if @past_due.nil?
      if user.schedule_type == 'schedule'
        run_schedule
      else
        run_schedule_spread
      end
    end
    # however you want to handle the ones that cant be scheduled before due date

  end
end
