require_relative 'day.rb'
require_relative 'task_placer.rb'
require_relative 'pref_time_builder.rb'
require_relative 'utility.rb'
require_relative 'scheduler_test_copy.rb'

def run_scheduler
	d = DateTime.now.midnight
	user_pref = {profile_type: 'early', start_time: change_dt(d, 7), end_time: change_dt(d, 18)}
	user = current_user
	tasks = []
	events = []
	user.tasks.map { |e| tasks << e}
	user.events.map { |e| events << e}
	main_calendar = Scheduler.new(user_pref, tasks, events)
	cal = main_calendar.schedule
	puts cal[0].to_s
	cal[0].each do |day|
		tasks = day.filled.select{|task| task.is_task?}
		tasks.each do |task|
			#updates here
		end
	end
end
