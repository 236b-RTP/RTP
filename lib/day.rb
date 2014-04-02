require 'date'
require_relative 'utility.rb'
require 'active_support/all'

class Block
	attr_accessor :t 
	def initialize (start, stop, type)
		@t = {:begin => start, :end => stop}
		@type = type
	end
	def is_task?
		return @type
	end

end

class Day
	attr_accessor :filled, :date
	def initialize(wake, sleep, date)
		daylength = sleep.hour - wake.hour
		@filled = []
		@date = date
		@sleep = change_dt(@date, sleep.hour)
		@wake = change_dt(@date, wake.hour)

	end

	def busy(time)
		busy = false
		@filled.each do |spot|
			#non incusive som times can abut eachother a to 2:00 b from 2:00 accepted
			busy ||= change_dt_sec(time.t[:begin], 1).between?(spot.t[:begin], spot.t[:end])
			busy ||= change_dt_sec(time.t[:end], -1).between?(spot.t[:begin], spot.t[:end]) 
			#check spot isnt between the time
			busy ||= change_dt_sec(spot.t[:begin], 1).between?(time.t[:begin], time.t[:end])
			busy ||= change_dt_sec(spot.t[:end], -1).between?(time.t[:begin], time.t[:end]) 

		end
		return busy
	end


	#events can be at the same time need to change shit
	def insert (start, fin, if_task)
		#preftimes made by preftime builder have the date when rise time was created 
		if start.between?(@wake, @sleep)&& fin.between?(@wake, @sleep)
			time = Block.new(start, fin, if_task)
			if !busy(time) && if_task
				@filled << time
				return true
			elsif !if_task
				@filled << time
				return true
			else
				return false
			end
		else
			return false
		end
	end

end

=begin
d = Day.new(change_dt(DateTime.now.midnight, 7),change_dt(DateTime.now.midnight, 14) , DateTime.now.midnight)
#b = Block.new(DateTime.now.to_time - 7*60**2, DateTime.now.to_time - 6*60**2, )

puts d.insert(change_dt(DateTime.now.midnight, 10), change_dt(DateTime.now.midnight, 12), false)
puts d.insert(change_dt(DateTime.now.midnight, 12), change_dt(DateTime.now.midnight, 13), true)
=end