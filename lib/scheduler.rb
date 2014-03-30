require_relative 'day.rb'
require_relative 'task_placer.rb'
require_relative 'pref_time_bulider.rb'

class PrefTime
	#dont need dates insert into a day which has date
	attr_accessor :pref, :time
	def initialize (pref, time, day)
		@pref = pref
		@time = time
	end

	def <=> (another)
		@pref <=> another.pref
	end
end

class Scheduler
	def initialize (tasks, events)
		user_pref = current_user.preferences
		#change to be users location time
		@today = DateTime.now
		@prefered_times = load_prefered_times(user_pref)
		@week = Array.new(7){|e|  e = Day.new(user_pref.start, user_pref.end, make_date(@today.wday, e))}
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

				check_day = @prefered_times[d%7].map.with_index{|e, i| PrefTime.new(e, i)}
				#custom sort on Preftimes
				best_times = check_day.sort.reverse

				while !best_times.empty? && scheduled == false do
					pref_time = best_times.shift
					busy = @week[d].busy(Block.new(pref_time.time, pref_time.time+best_task[:duration]))
					if !busy && @week[d].date < best_task[:due_date]
						scheduled = true
						@week[d].insert(Block.new(pref_time.time, pref_time.time+best_task[:duration]))
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

		return @week couldnt_schedule

	end

	#takes in array and user id, fills array with events that user owns
	def load_events(week)
		events = current_user.events
		#get events from database put in week days
		week.each do|wday| 
			deay_events = events.select{|ev| e[:start_date].to_date == wday.date.to_date}
			day_events.each do |d_e|
				#make e a block object
				day.insert(Block.new(d_e[:start_time], d_e[:end_time]), false)
			end
		end 

	end

	def load_prefered_times(pref)
		#need some predefined schemas for what times users prefer
		@prefered_times = week_preferences(pref)
	end

	def make_date(today, weekday)
		return today > weekday ? DateTime.now +(7-today+weekday) : DateTime.now +(weekday-today)
	end
end




