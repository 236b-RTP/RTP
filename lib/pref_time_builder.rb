require 'date'

def week_preferences (pref)
	if('early' == pref[:profile_type])
		return earlybird(pref[:start_time], pref[:end_time])
	elsif ('late' == pref[:profile_type])
		return nightowl(pref[:start_time], pref[:end_time])
	elsif('mix' == pref[:profile_type])
		return default(pref[:start_time], pref[:end_time])
	end
end

def earlybird (rise, bed)
	day = bed.hour - rise.hour
	week = Array.new(7){|d| d = Array.new(day).map.with_index{|h, i| prefh(i,1,day)}}
	return week
end

def nightowl (rise, bed)
	day = bed.hour - rise.hour
	week = Array.new(7){|d| d = Array.new(day,0).map.with_index{|h, i| prefh(i,2,day)}}
	return week
end

def default (rise, bed)
	day = bed.hour - rise.hour
	week = Array.new(7){|d| d = Array.new(day,0).map.with_index{|h, i| prefh(i,3,day)}}
	return week
end


def prefh (hour,type, day)
	# 1 is early bird 2 is nightowl
	if(type == 1)
		if hour < day/3 then return 10 end
		if hour>= day/3 && hour < (day/3)*2 then return 7 end
		if hour>= (day/3)*2 then return 4 end
	end

	if(type == 2)
		if hour < day/3 then return 4 end
		if hour>=day/3 && hour < (day/3)*2 then return 7 end
		if hour>=(day/3)*2 then return 10 end
	end

	if(type == 3)
		if hour  < day/3 then return 8 end
		if hour >= day/3 && hour < (day/3)*2 then return 10 end
		if hour >= (day/3)*2 then return 8 end
	end
end

person = {profile_type: 'early', start_time: (DateTime.now.to_time - (7*60*60)).to_datetime, end_time: (DateTime.now.to_time + (5*60*60)).to_datetime}

wp = week_preferences(person)

puts wp.to_s

person = {profile_type: 'mix', start_time: (DateTime.now.to_time - (7*60*60)).to_datetime, end_time: (DateTime.now.to_time + (5*60*60)).to_datetime}

wp = week_preferences(person)

puts wp.to_s

person = {profile_type: 'late', start_time: (DateTime.now.to_time - (7*60*60)).to_datetime, end_time: (DateTime.now.to_time + (5*60*60)).to_datetime}

wp = week_preferences(person)

puts wp.to_s