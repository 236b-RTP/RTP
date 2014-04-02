require 'active_support/all'

def change_dt(d, amount)
	(d.to_time + amount * 60**2).to_datetime
end

def make_date(today, weekday)
	return today > weekday ? (DateTime.now + (7-today+weekday)).midnight : (DateTime.now + (weekday-today)).midnight
end

