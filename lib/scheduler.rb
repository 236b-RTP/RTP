require_relative 'day.rb'
require_relative 'task_placer.rb'
require_relative 'pref_time_bulider.rb'

class PrefTime
	attr_accessor :pref, :time, :date
	def initialize (pref, time)
		@pref = pref
		@time = time
		@date = get_date(week_day)
	end

	def get_date (week_day)
		#need to convert array spot to an actual date
	end

	def <=> (another)
		@pref <=> another.pref
	end
end

class Scheduler
	def initialize (tasks, events)
		@prefered_times = Array.new(7){Array.new(8,0)}
		@prefered_times_test = [[ 10, 10, 5, 2, 3, 0, 8, 8 ], 
								[ 10, 10, 5, 2, 3, 0, 8, 8 ], 
								[ 10, 10, 5, 2, 3, 0, 8, 8 ], 
								[ 10, 10, 5, 2, 3, 0, 8, 8 ], 
								[ 10, 10, 5, 2, 3, 0, 8, 8 ], 
								[ 10, 10, 5, 2, 3, 0, 8, 8 ],
								[ 10, 10, 5, 2, 3, 0, 8, 8 ],
								]

		load_prefered_times
		@week = Array.new(7, Day.new)
		load_events
		task_placer = TaskPlacer.new
		@tasks = task_placer.order_tasks(tasks)
		
	end

	def schedule(week_day, time)
		#making a deep copy
		remaining = Marshal.load(Marshal.dump(@tasks))
		couldnt_schedule= []
		while !remaining.empty? do
			best_task remaining.shift
			scheduled = false
			#find prefered poition closest to current time
			d = week_day

			#will need a circular check and note that it is circular 
			#should grab week schedule one week from current wednessday to next tuesday 
			
			tested_week = false
			while !scheduled &&  !tested_week do 

				check_day = @prefered_times[d%7].map.with_index{|e, i| PrefTime.new(e, i)}
				best_times = check_day.sort.reverse
				while !best_times.empty? do

					pref_time = best_times.shift
					#probably could do something about that remaining[0][:duration] since ugle
					busy = @week[d].busy(Block.new(pref_time.time, pref_time.time+best_task[:duration]))
					if !busy && pref_time.date < best_task[:due_date]
						scheduled = true
						@week[d].insert(Block.new(pref_time.time, pref_time.time+best_task[:duration]))
					end
				end
				d+=1 

				#some tested week update if gone through week

			end

			if scheduled == false
				couldnt_schedule << best_task
			end
		end

		if !couldnt_schedulse.empty?
			#do sme error for eadh not scheduled
		end

	end


	def load_events
		#get events from database put in week days


	end

	def load_prefered_times
		#need some predefined schemas for what tmies users prefer
		pref = Preferecnes.where(user_id = <user goes here>)	
		@prefered_times = week_preferences(pref)
	end


end