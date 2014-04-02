require 'date'
require_relative 'utility.rb'

class PrefTime
	#dont need dates insert into a day which has date
	attr_accessor :pref, :time
	def initialize (pref, hour, morning)
		@pref = pref
		@time = change_dt(morning.to_datetime, hour)
	end

	def <=> (another)
		@pref <=> another.pref
	end
end

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
	#puts day.to_s
	week = Array.new(7){|d| d = Array.new(day){|i| prefh(i,1,day, make_date(@today.wday, d).midnight())}}
	return week
end

def nightowl (rise, bed)
	day = bed.hour - rise.hour
	week = Array.new(7){|d| d = Array.new(day){|i| prefh(i,2,day, make_date(@today.wday, d).midnight())}}
	return week
end

def default (rise, bed)
	day = bed.hour - rise.hour
	week = Array.new(7){|d| d = Array.new(day){|i| prefh(i,3,day, make_date(@today.wday, d).midnight())}}
	return week
end


def prefh (hour, type, day, rise)
	# 1 is early bird 2 is nightowl
	if(type == 1)
		if hour < day/3 then return PrefTime.new(10, hour, rise) end
		if hour>= day/3 && hour < (day/3)*2 then return PrefTime.new(7, hour, rise) end
		if hour>= (day/3)*2 then return PrefTime.new(4, hour, rise) end
	end

	if(type == 2)
		if hour < day/3 then return PrefTime.new( 4, hour, rise) end
		if hour>=day/3 && hour < (day/3)*2 then return PrefTime.new( 7, hour, rise)  end
		if hour>=(day/3)*2 then return PrefTime.new( 10, hour, rise) end
	end

	if(type == 3)
		if hour  < day/3 then return PrefTime.new(7, hour, rise) end
		if hour >= day/3 && hour < (day/3)*2 then return PrefTime.new(10, hour, rise) end
		if hour >= (day/3)*2 then return PrefTime.new(7, hour, rise) end
	end
end

=begin
d = DateTime.new(2014, 4, 2, 8, 0, 0)

person = {profile_type: 'early', start_time: change_dt(d, 0), end_time: change_dt(d, 7)}

wp = week_preferences(person)

puts wp.to_s

person = {profile_type: 'mix', start_time: change_dt(d, 0), end_time: change_dt(d, 7)}

wp = week_preferences(person)

puts wp.to_s

person = {profile_type: 'late', start_time: change_dt(d, 0), end_time: change_dt(d, 7)}

wp = week_preferences(person)

puts wp.to_s
=end
