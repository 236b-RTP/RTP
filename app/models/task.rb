class Task < ActiveRecord::Base
  has_one :task_event, as: :item
  has_one :user, through: :task_event

  def schedule!
    scheduler = SchedulerResultsHandler.new(user, self)
    scheduler.run_schedule
  end

  class << self
    def reschedule!(user)
      scheduler = SchedulerResultsHandler.new(user)
      scheduler.run_schedule
    end
  end
end
