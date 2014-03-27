require_relative 'day.rb'
require_relative 'task_placer.rb'
require_relative 'pref_time_bulider.rb'

class PrefTime
	attr_accessor :pref, :time, :date
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
		user_pref = Preferences.where(user_id = <user goes here>)
		#change to be users location time
		@today = Time.now
		@prefered_times = load_prefered_times(user_pref)
		@week = Array.new(7){|e|  e = Day.new(user_pref.start, user_pref.end, make_date(@today.wday, e))}
		load_events(@week, user_id)
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

			#will need a circular check and note that it is circular 
			#should grab week schedule one week from current wednessday to next tuesday 
			
			tested_week = 0
			while !scheduled &&  tested_week <7 do 

				check_day = @prefered_times[d%7].map.with_index{|e, i| PrefTime.new(e, i)}
				best_times = check_day.sort.reverse
				while !best_times.empty? do

					pref_time = best_times.shift
					#probably could do something about that remaining[0][:duration] since ugly
					busy = @week[d].busy(Block.new(pref_time.time, pref_time.time+best_task[:duration]))
					if !busy && pref_time.date < best_task[:due_date]
						scheduled = true
						@week[d].insert(Block.new(pref_time.time, pref_time.time+best_task[:duration]))
					end
				end
				d+=1
				tested_week+=1 

			end

			if scheduled == false
				couldnt_schedule << best_task
			end
		end

		if !couldnt_schedule.empty?
			#do sme error for eadh not scheduled
		end

		return @week

	end

	#takes in array and user id, fills array with events that user owns
	def load_events(week)
		events = Events.where(belongs_to == <user id goes here>)
		#get events from database put in week days


	end

	def load_prefered_times(pref)
		#need some predefined schemas for what times users prefer
		@prefered_times = week_preferences(pref)
	end

	def make_date(today, weekday)
		return today > weekday ? Time.now +(60*60*24*(7-today+weekday): Time.now +(60*60*24*(weekday-today)
	end
end