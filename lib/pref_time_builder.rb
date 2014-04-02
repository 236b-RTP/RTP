require 'date'
require_relative 'utility.rb'
require 'active_support/all'

class PrefTime
	#dont need dates insert into a day which has date
	attr_accessor :pref, :time
	def initialize (pref, hour, morning)
		#puts "hour in preftime " + hour.to_s
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
	@today = DateTime.now
	day = bed.hour - rise.hour
	week = Array.new(7){|d| d = Array.new(day){|i| i = prefh(i,1,day, change_dt(make_date(@today.wday, d), rise.hour))}}
	return week
end

def nightowl (rise, bed)
	@today = DateTime.now
	day = bed.hour - rise.hour
	week = Array.new(7){|d| d = Array.new(day){|i| i = prefh(i,2,day, change_dt(make_date(@today.wday, d), rise.hour))}}
	return week
end

def default (rise, bed)
	@today = DateTime.now
	day = bed.hour - rise.hour
	week = Array.new(7){|d| d = Array.new(day){|i| i = prefh(i,3,day, change_dt(make_date(@today.wday, d), rise.hour))}}
	return week
end


def prefh (hour, type, day, rise)
	# 1 is early bird 2 is nightowl
	puts "prefh" + hour.to_s

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
d = DateTime.now.midnight
puts " rise "+ d.hour.to_s

puts "change by 0 " + change_dt(d, 8).hour.to_s

person = {profile_type: 'early', start_time: change_dt(d, 8), end_time: change_dt(d, 15)}

wp = week_preferences(person)

wp.each do |d|
	d.each do|h|
		puts h.pref
		puts h.time
	end
end

person = {profile_type: 'mix', start_time: change_dt(d, 0), end_time: change_dt(d, 7)}

wp = week_preferences(person)

puts wp.to_s

person = {profile_type: 'late', start_time: change_dt(d, 0), end_time: change_dt(d, 7)}

wp = week_preferences(person)

puts wp.to_s

=end