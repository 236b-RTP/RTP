def run_scheduler
	user_pref = {profile_type: 'early', start_time: change_dt(d, 7), end_time: change_dt(d, 18)}
	user = current_user
	
	main_calendar = Scheduler.new(user_pref, user.tasks, user.events)
	cal = main_calendar.schedule
=begin
	cal[0].each do |day|
		tasks = day.filled.select{|task| task.is_task?}
		tasks.each do |task|
			#updates here
		end
	end
=end

end			