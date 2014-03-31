def change_dt(d, amount)
	(d.to_time + amount * 60**2).to_datetime
end