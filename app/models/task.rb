class Task < ActiveRecord::Base
  has_one :task_event, as: :item
  has_one :user, through: :task_event

  def schedule!
    scheduler = Scheduler.new(user, self)
    scheduler.schedule
  end

  class << self
    def reschedule!(user)
      scheduler = Scheduler.new(user)
      scheduler.schedule
    end
  end
end
