require 'time_utilities'

class Scheduler
  def initialize(user, task = nil)
    @user = user
    @user_preference = @user.preference
    @today = DateTime.now
    @preferred_times = PreferredTime.week_preferences(@user_preference)
    @week = Array.new(7) { |e| Day.new(@user_preference.start_time, @user_preference.end_time, make_date(@today.wday, e)) }

    load_events(@user.events)

    tasks = @user.tasks.select { |task| task.start_date.present? }
    tasks.reject!(&:completed?) # filter out completed tasks
    if task.present?
      tasks << task
    end

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
      # find preferred position closest to current time
      d = @today.wday

      while !scheduled && d < @today.wday + 7 do
        check_day = @preferred_times[d%7]
        #custom sort on Preftimes
        best_times = check_day.sort.reverse
=begin
        if(@user_preference.profile_type == 'late'){
          #does a stable sort so reverses the times and then sorts of preferences eg best time is latest time with highest priority
          best_times = reverse_pref_gravity(checkday.sort{|x,y| y.time<=>x.time})
        }
=end
        while !best_times.empty? && scheduled == false do
          pref_time = best_times.shift
          # make sure before scheduling before duedate and not before the current time
          if @week[d].date < best_task[0].due_date && @today <= pref_time
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
    #why is this here should be in outer script
    @week.each do |day|
      tasks = day.filled.select { |task| task.is_task? }
      tasks.each do |block|
        block.item.update_attributes(start_date: block.t[:begin], end_date: block.t[:end])
      end
    end
  end
=begin

  def schedule_spread
    remaining = Marshal.load(Marshal.dump(@tasks))
    pre_time_ar = Marshal.load(Marshal.dump(@preferred_times))
    while !multi_arr_empty?(pre_time_ar) && !remaining.empty? do
      #need to remove best times from pref time ar - may not do what is intended
      best_times = weeks_best_times(pre_time_ar)
      #may or may not work
      pre_time_ar-best_times

      best_times.each do |slot|
          #for times match best tasks or for tasks match best times????

          scheduled = false
          count = 0
          while count<remaining.size && scheduled == false
            if slot.time < remaining[count].due_date
              task = remaining[count]
              day = @week.select{ |day| slot.time.to_date == day.date.to_date }[0]
              if @week[d].date < best_task[0].due_date && @today <= pref_time
                scheduled = day.insert(pref_time.time, change_dt(pref_time.time, (task.duration / 60)), true, task)
              end
              if scheduled
                remaining.delete_at(count)
              end
            end
            count += 1
          end
      end

    end
    #need to work out script issue
    return @week, remaining
  end
=end
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
=begin
  #need to add null checks max may be null
  def weeks_best_times(preftimes)
    best_times = []
    preftimes.each do |day|
      #get times with highest priority get earliest time?? may not want earliest time want something grr
      candidates = day.select{|p| p.pref == day.max.pref}
      # if night owl take latest of best times
      if !candidates.empty?
        if(user_preference.profile_type == 'late')
          best_time = candidates.sort{|a,b| b.time<=>a.time}.shift
        else
          best_time = candidates.sort{|a,b| a.time<=>b.time}.shift
        end
        best_times << best_time
      end
    end
    return best_times
  end
=end
end
