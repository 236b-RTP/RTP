require 'time_utilities'

class Scheduler
  def initialize(user, task)
    @user = user
    @user_preference = @user.preference
    @today = DateTime.now
    @prefered_times = PreferredTime.week_preferences(@user_preference)
    @week = Array.new(7) { |e| Day.new(@user_preference.start_time, @user_preference.end_time, make_date(@today.wday, e)) }

    load_events(@user.events)

    tasks = @user.tasks.select { |task| task.start_date.present? }
    tasks << task

    task_placer = TaskPlacer.new(tasks)
    @tasks = task_placer.order_tasks
  end

  def schedule
    #making a deep copy
    remaining = Marshal.load(Marshal.dump(@tasks))
    couldnt_schedule = []
    while !remaining.empty? do
      best_task = remaining.shift
      scheduled = false
      #find prefered poition closest to current time
      d = @today.wday

      while !scheduled && d < @today.wday + 7 do
        check_day = @prefered_times[d%7]
        #custom sort on Preftimes
        best_times = check_day.sort.reverse

        while !best_times.empty? && scheduled == false do
          pref_time = best_times.shift
          if @week[d].date < best_task[0].due_date
            scheduled = @week[d].insert(pref_time.time, change_dt(pref_time.time, (best_task[0].duration / 60)), true, best_task[0])
          end
        end

        d += 1
      end

      if scheduled == false
        couldnt_schedule << best_task
      end
    end

    if !couldnt_schedule.empty?
      #do some error for each not scheduled
    end

    return @week, couldnt_schedule
  end

  private

  def load_events(events)
    @week.each do |wday|
      day_events = events.select { |ev| ev.start_date.to_date == wday.date.to_date }
      day_events.each do |d_e|
        #make e a block object
        wday.insert(d_e.start_date, d_e.end_date, false, d_e)
      end
    end
  end
end