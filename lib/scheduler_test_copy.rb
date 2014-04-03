require_relative 'day.rb'
require_relative 'task_placer.rb'
require_relative 'pref_time_builder.rb'
require_relative 'utility.rb'
require 'active_support/all'
require 'pry'

class Scheduler
	def initialize (preferences, tasks, events)
		user_pref = preferences
		#change to be users location time
		@today = DateTime.now
		@prefered_times =  week_preferences(user_pref)
		@week = Array.new(7){|e|  e = Day.new(user_pref[:start_date], user_pref[:end_date], make_date(@today.wday, e))}
		load_events(events)
		task_placer = TaskPlacer.new
		@tasks = task_placer.order_tasks(tasks)
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
						scheduled = @week[d].insert(pref_time.time, change_dt(pref_time.time, (best_task[0][:duration]/60)), true, best_task[0])
					end
				end
				d+=1

			end

			if scheduled == false
				couldnt_schedule << best_task
			end
		end

		if !couldnt_schedule.empty?
			#do some error for eadh not scheduled
		end

		return @week, couldnt_schedule

	end

	#takes in array and user id, fills array with events that user owns
	def load_events(event_arr)
		events = event_arr
		#get events from database put in week days
		@week.each do|wday| 
			day_events = events.select{|ev| ev[:start_date].to_date == wday.date.to_date}
			puts
			day_events.each do |d_e|
				#make e a block object
				wday.insert(d_e[:start_date], d_e[:end_date], false, d_e)
			end
		end 
	
	end

end


=begin
d = DateTime.now.midnight


user_pref = {profile_type: 'early', start_time: change_dt(d, 7), end_time: change_dt(d, 18)}

#change to be users location time
@today = DateTime.now
		
@week = Array.new(7){|e|  e = Day.new(user_pref[:start_time], user_pref[:end_time], make_date(@today.wday, e))}



@week.each do |day|
	puts "here"
	puts day.date.to_s
end




es = change_dt(DateTime.now.midnight, 12)
ee = change_dt(DateTime.now.midnight, 14)
es2 = change_dt(DateTime.now.midnight, 13)
ee2 = change_dt(DateTime.now.midnight, 15)
es3 = change_dt(DateTime.now.midnight, 15)
ee3 = change_dt(DateTime.now.midnight, 17)
events = [{start_date: es, end_date: ee}, {start_date: es + 1, end_date: ee + 1}, {start_date: es + 2, end_date: ee + 2}, 
	{start_date: es + 3, end_date: ee + 3}, {start_date: es + 4, end_date: ee + 4}, {start_date: es + 5, end_date: ee + 5},
	 {start_date: es + 6, end_date: ee + 6},]

events = [{start_date: es, end_date: ee}, {start_date: es2, end_date: ee2}, {start_date: es3, end_date: ee3},
	{start_date: es + 1, end_date: ee + 1}, {start_date: es + 2, end_date: ee + 2}, {start_date: es + 3, end_date: ee + 3}, 
	{start_date: es + 4, end_date: ee + 4}, {start_date: es + 5, end_date: ee + 5}, {start_date: es + 6, end_date: ee + 6},]

load_events(@week, events)

@week.each do |day|
	puts day.filled.to_s
end


today = DateTime.now
tomorrow = today+1
start = DateTime.now
finishTime = DateTime.now +1

tasks = [{title: "hello1*****", start_date: start, end_date: finishTime, priority: 3 , created_at: today, due_date: tomorrow, duration: 60}, 
	{title: "hello2*****", start_date: start, end_date: finishTime, priority: 1 , created_at: today, due_date: tomorrow, duration: 60},
	{title: "hello3*****", start_date: start, end_date: finishTime, priority: 1 , created_at: today, due_date: tomorrow, duration: 60},
	{title: "hello4*****", start_date: start, end_date: finishTime, priority: 1 , created_at: today, due_date: tomorrow, duration: 60},
	{title: "hello5*****", start_date: start, end_date: finishTime, priority: 1 , created_at: today, due_date: tomorrow, duration: 60},
	{title: "hello6*****", start_date: start, end_date: finishTime, priority: 1 , created_at: today, due_date: tomorrow, duration: 60},
	{title: "hello7*****", start_date: start, end_date: finishTime, priority: 1 , created_at: today, due_date: tomorrow, duration: 60},
	{title: "hello8*****", start_date: start, end_date: finishTime, priority: 1 , created_at: today, due_date: tomorrow, duration: 60}]

s = Scheduler.new(user_pref, tasks, events)

ar = s.schedule

ar[0].each do |day|
	puts "date"+day.date.to_s
	day.filled.each do |b|
		puts "\t is task? "+b.is_task?.to_s
		puts "\t start time "+b.t[:begin].to_s
		puts "\t end time "+b.t[:end].to_s
	end
end
=end

