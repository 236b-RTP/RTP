require_relative 'day.rb'
require_relative 'task_placer.rb'
require_relative 'pref_time_builder.rb'
require_relative 'utility.rb'
require_relative 'scheduler_test_copy.rb'

def run_scheduler
	d = DateTime.now.midnight
	user_pref = {profile_type: 'early', start_time: change_dt(d, 7), end_time: change_dt(d, 18)}
	user = current_user
	tasks, events = [], []
	user.tasks.map { |e| tasks << e}
	user.events.map { |e| events << e}
	main_calendar = Scheduler.new(user_pref, tasks, events)
	cal = main_calendar.schedule
	puts cal[0].to_s
	cal[0].each do |day|
		tasks = day.filled.select{|task| task.is_task?}
		tasks.each do |block|
			block.item.update(start_date: block.t[:begin], end_date: block.t[:end])
		end
	end
	puts "************** SECOND CALL TO CAL[0]"
	puts cal[0].to_s
end
