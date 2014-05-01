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
    remaining = @tasks
    #all tasks that couldnt be scheduled because past due or didnt fit
    couldnt_schedule = []
    #tasks that couldnt be scheduled before when due
    past_due = []
    while !remaining.empty? do
      best_task = remaining.shift
      scheduled = false
      #find preferred position closest to current time
      d = @today.wday

      while !scheduled && d < @today.wday + 7 do
        check_day = @preferred_times[d%7]
        #custom sort on Preftimes
        best_times = check_day.sort.reverse

        if(@user_preference.profile_type == 'late') then
          #does a stable sort so reverses the times and then sorts of preferences eg best time is latest time with highest priority
          best_times = reverse_pref_gravity(checkday.sort{|x,y| y.time<=>x.time})
        end

        while !best_times.empty? && scheduled == false do
          pref_time = best_times.shift
          #make sure before scheduling before duedate and not before the current time
          if pref_time.time < best_task[0].due_date && @today <= pref_time.time
            scheduled = @week[d].insert(pref_time.time, change_dt(pref_time.time, (best_task[0].duration / 60)), true, best_task[0])
          elsif pref_time.time >= best_task[0].due_date
            past_due << best_task
          end

        end

        d += 1
      end

      if scheduled == false
        couldnt_schedule << best_task
      end
    end
    return @week, couldnt_schedule, past_due
  end

  def schedule_spread
    remaining = @tasks
    couldnt_schedule = []
    past_due = []
    pref_time_ar = Marshal.load(Marshal.dump(@preferred_times))

    
    while !multi_arr_empty?(pref_time_ar) && !remaining.empty? do
      #need to remove best times from pref time ar - may not do what is intended
      best_times = weeks_best_times(pref_time_ar)
      puts "BEFORE:"

      pref_time_ar.each do |element|
        element.each do |pref_element|
          puts "pref = #{pref_element.pref}, time = #{pref_element.time}"
        end
      end
      puts "best times"
      best_times.each do |e|
          puts "pref = #{e.pref}, time = #{e.time}"
      end
      #binding.pry
      pref_time_ar = pref_time_ar.map{|day| day - best_times}
      binding.pry
=begin
      puts "AFTER:"
      pref_time_ar.each do |element|
        element.each do |pref_element|
          puts "pref = #{pref_element.pref}, time = #{pref_element.time}"
        end
      end
=end
      best_times.each do |slot|
          #for times match best tasks or for tasks match best times????
          scheduled = false
          count = 0
          task = nil
          while count<remaining.size && scheduled == false
            if slot.time < remaining[count][0].due_date
              task = remaining[count][0]
              day = @week.select{ |day| slot.time.to_date == day.date.to_date }[0]
              if @today <= slot.time
                scheduled = day.insert(slot.time, change_dt(slot.time, (task.duration / 60)), true, task)
              end
            end
            if !task.nil? && slot.time >= task.due_date
              past_due << task
            end
            if scheduled
              remaining.delete_at(count)
            end
            count += 1
          end
       end
    end
    #need to work out script issue
    return @week, remaining, past_due
  end
  #made load_events public to test it

  def load_events(events)
    @week.each do |wday|
      day_events = events.select { |ev| ev.start_date.to_date == wday.date.to_date }
      day_events.each do |d_e|
        #make e a block object
        wday.insert(d_e.start_date, d_e.end_date, false, d_e)
      end
    end
  end

  #need to add null checks max may be null
  def weeks_best_times(preftimes)
    best_times = []
    d = @today.wday
    while d < @today.wday + 7 do
      day = preftimes[d%7]
      #max returns the first object with the highest pref then get the pref to compair
      candidates = day.select{|p| p.pref == day.max.pref}
      # if night owl take latest of best times
      if !candidates.empty?
        if(@user_preference.profile_type == 'late')
          best_time = candidates.sort{|a,b| b.time<=>a.time}.shift
        else
          best_time = candidates.sort{|a,b| a.time<=>b.time}.shift
        end
        best_times << best_time
      end
      d+=1
    end
    return best_times
  end


end