class Task < ActiveRecord::Base
  has_one :task_event, as: :item
  has_one :user, through: :task_event

  def schedule!
    scheduler = Scheduler.new(user)
    cal = scheduler.schedule
    cal[0].each do |day|
      tasks = day.filled.select { |task| task.is_task? }
      tasks.each do |block|
        block.item.update_attributes(start_date: block.t[:begin], end_date: block.t[:end])
      end
    end
  end
end
