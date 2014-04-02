require_relative 'day.rb'
require_relative 'task_placer.rb'
require_relative 'pref_time_builder.rb'
require_relative 'utility.rb'
require 'active_support/all'
require 'pry'

class Scheduler
	def initialize (tasks, events)
		user_pref = current_user.preferences
		#change to be users location time
		@today = DateTime.now
		@prefered_times =  week_preferences(user_pref)
		@week = Array.new(7){|e|  e = Day.new(user_pref[:start_time], user_pref[:end_time], make_date(@today.wday, e))}
		load_events(@week)
		task_placer = TaskPlacer.new
		@tasks = task_placer.order_tasks(tasks)
		#returns weekday number starting at 0 for sunday
		#this may only give server time and not loval time of user so ????
				
	end

	def schedule(week_day, time)
		#making a deep copy
		remaining = Marshal.load(Marshal.dump(@tasks))
		couldnt_schedule = []
		while !remaining.empty? do
			best_task = remaining.shift
			scheduled = false
			#find prefered poition closest to current time
			d = @today.wday
			
			while !scheduled &&  d <  @today.wday+7 do 
				check_day = @prefered_times[d%7]
				#custom sort on Preftimes
				best_times = check_day.sort.reverse

				while !best_times.empty? && scheduled == false do
					pref_time = best_times.shift
					if @week[d].date < best_task[:due_date]
						scheduled = @week[d].insert(pref_time.time, change_dt(pref_time.time, (best_task[:duration]/60)), true)
					end
				end
				d+=1

			end

			if scheduled == false
				couldnt_schedule << best_task
			end
		end

		if !couldnt_schedule.empty?
			#do sme error for eadh not scheduled
		end

		return @week, couldnt_schedule

	end

	#takes in array and user id, fills array with events that user owns
	def load_events(week)
		events = current_user.events
		#get events from database put in week days
		week.each do|wday| 
			deay_events = events.select{|ev| ev[:start_date].to_date == wday.date.to_date}
			day_events.each do |d_e|
				#make e a block object
				day.insert(d_e[:start_time].hour, d_e[:end_time].hour, false)
			end
		end 

	end

	def make_date(today, weekday)
		return today > weekday ? DateTime.now + (7-today+weekday) : DateTime.now + (weekday-today)
	end
end


def load_events(week, event_arr)
	events = event_arr
	#get events from database put in week days
	week.each do|wday| 
		day_events = events.select{|ev| ev[:start_time].to_date == wday.date.to_date}
		puts
		day_events.each do |d_e|
			#make e a block object
			wday.insert(d_e[:start_time], d_e[:end_time], false)
		end
	end 

end





d = DateTime.new(2014, 3, 31, 8, 0, 0)

user_pref = {profile_type: 'early', start_time: change_dt(d, 0), end_time: change_dt(d, 7)}

#change to be users location time
@today = DateTime.now
		
@week = Array.new(7){|e|  e = Day.new(user_pref[:start_time], user_pref[:end_time], make_date(@today.wday, e))}

@week.each do |day|
	puts day.date.to_s
end

es = DateTime.new(2014, 4, 1, 11,0, 0)
ee = DateTime.new(2014, 4, 1, 14,0, 0)
events = [{start_time: es, end_time: ee}, {start_time: es + 1, end_time: ee + 1}, {start_time: es + 2, end_time: ee + 2}, 
	{start_time: es + 3, end_time: ee + 3}, {start_time: es + 4, end_time: ee + 4}, {start_time: es + 5, end_time: ee + 5}, {start_time: es + 6, end_time: ee + 6},]

load_events(@week, events)
=begin
@week.each do |day|
	puts day.filled.to_s
end
=end
