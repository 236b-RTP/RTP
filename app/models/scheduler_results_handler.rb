class SchedulerResultsHandler
  #allow for growth in handeling results from scheduller including week updates and past due returns
  def initialize(user, task = nil)
    @user = user
    @task = task
  end

  #run different scheduling schemas
  def run_schedule
    scheduler = Scheduler.new(@user, @task)
    results = scheduler.schedule
    #results[0] = week, [1] = couldnt schedule, [2] = past_due
    update_tasks(results[0])
  end

  private

  #remove updating the databasae from scheduler
  def update_tasks(week)
    week.each do |day|
      tasks = day.filled.select { |task| task.is_task? }
      tasks.each do |block|
        block.item.update_attributes(start_date: block.t[:begin], end_date: block.t[:end])
      end
    end
  end
end