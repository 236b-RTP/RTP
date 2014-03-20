def week_preferences (preferences)
	if(early = pref.type)
		return earlybird(pref.start, pref.end)
	elsif (night = pref.type)
		return nightowl(pref.start, pref.end)
	elsif(defailt = pref.type)
		return default(pref.start, pref.end)
	end


def earlybird (rise, bed)
	day = bed.hour - rise.hour
	week = Array.new(7){|d| d = Array.new(day,0).map.with_index{|h, i| prefh(e,1,day)}}
	return week
end

def nightowl (rise, bed)
	day = bed.hour - rise.hour
	week = Array.new(7){|d| d = Array.new(day,0).map.with_index{|h, i| prefh(e,2,day)}}
	return week
end

def default
	day = bed.hour - rise.hour
	week = Array.new(7){|d| d = Array.new(day,0).map.with_index{|h, i| prefh(e,3,day)}}
	return week
end


def prefh (hour,type, day)
	# 1 is early bird 2 is nightowl
	if(type == 1)
		if hour <= day/3 return 10
		if hour> day/3 && hour <= (day/3)*2 return 7
		if hour> (day/3)*2 return 4
	end

	if(type == 2)
		if hour <= day/3 return 4
		if hour> day/3 && hour <= (day/3)*2 return 7
		if hour> (day/3)*2 return 10
	end

	if(type == 3)
		if hour <= day/3 return 8
		if hour> day/3 && hour <= (day/3)*2 return 10
		if hour> (day/3)*2 return 8
	end
 
end