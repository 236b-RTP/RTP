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

def multi_arr_empty?(arr)
  arr.empty? || arr.map(&:empty?).all?
end


class Array
  def stable_sort
      n = 0
      sort_by {|x| n+= 1; [x, n]}
  end
end

def reverse_pref_gravity(array)
	if(array.class == Array)
		return array.stable_sort
	else
		raise ArgumentError
	end
end
