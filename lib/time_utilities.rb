def change_dt(d, amount)
  (d.to_time + amount * 60**2).to_datetime
end

def make_date(today, weekday)
  if today > weekday
    (DateTime.now + (7 - today + weekday)).midnight
  else
    (DateTime.now + (weekday - today)).midnight
  end
end

def change_dt_sec(d, amount)
  (d.to_time + amount).to_datetime
end