user_pref = {profile_type: 'early', start_time: change_dt(d, 7), end_time: change_dt(d, 18)}
user = current_user

main_calendar = Scheduler.new(user_pref, user.tasks, user.events)
main_calendar.schedule