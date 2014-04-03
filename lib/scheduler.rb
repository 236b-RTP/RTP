require_relative 'day.rb'
require_relative 'task_placer.rb'
require_relative 'pref_time_builder.rb'
require_relative 'utility.rb'
require 'active_support/all'
require 'pry'

class Scheduler
	def initialize ()
		user_pref = current_user.preference
		#change to be users location time
		@today = DateTime.now
		@prefered_times =  week_preferences(user_pref)
		@week = Array.new(7){|e|  e = Day.new(user_pref[:start_date], user_pref[:end_date], make_date(@today.wday, e))}
		load_events
		task_placer = TaskPlacer.new
		@tasks = task_placer.order_tasks(current_user.tasks)
		#returns weekday number starting at 0 for sunday
		#this may only give server time and not loval time of user so ????
				
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
			
			while !scheduled &&  d <  @today.wday+7 do 
				check_day = @prefered_times[d%7]
				#custom sort on Preftimes
				best_times = check_day.sort.reverse

				while !best_times.empty? && scheduled == false do
					pref_time = best_times.shift
					if @week[d].date < best_task[0][:due_date]
						scheduled = @week[d].insert(pref_time.time, change_dt(pref_time.time, (best_task[0][:duration]/60)), true)
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
	def load_events
		events = current_user.events
		#get events from database put in week days
		@week.each do|wday| 
			day_events = events.select{|ev| ev[:start_date].to_date == wday.date.to_date}
			puts
			day_events.each do |d_e|
				#make e a block object
				wday.insert(d_e[:start_date], d_e[:end_date], false)
			end
		end
	end

end


def load_events(week, event_arr)
	events = event_arr
	#get events from database put in week days
	week.each do|wday| 
		day_events = events.select{|ev| ev[:start_date].to_date == wday.date.to_date}
		puts
		day_events.each do |d_e|
			#make e a block object
			wday.insert(d_e[:start_date], d_e[:end_date], false)
		end
	end 

end

