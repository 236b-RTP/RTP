require 'date'
require_relative 'utility.rb'
require 'active_support/all'

class Block
	attr_accessor :t
	def initialize (start, stop)
		@t = {:begin => start, :end => stop}
	end
end

class Day
	attr_accessor :filled, :date
	def initialize(wake, sleep, date)
		daylength = sleep.hour - wake.hour
		@filled = []
		@date = date 
		#@day = Array.new(daylength, 0)

	end

	def busy(time)
		busy = false
		@filled.each do |spot|
			#non incusive som times can abut eachother a to 2:00 b from 2:00 accepted
			busy ||= betwixt?(time.t[:begin], spot.t[:begin], spot.t[:end])
			busy ||= betwixt?(time.t[:end], spot.t[:begin], spot.t[:end])
			#check spot isnt between the time
			busy ||= betwixt?(spot.t[:begin], time.t[:begin], time.t[:end])
			busy ||= betwixt?(spot.t[:end], time.t[:begin], time.t[:end])

		end
		return busy
	end


	#events can be at the same time need to change shit
	def insert (start, fin, if_task)
		#preftimes made by preftime builder have the date when rise time was created 
		time = Block.new(start, fin)
		if !busy(time) && if_task
			@filled << time
			return true
		elsif !if_task
			@filled << time
			return true
		else
			return false
		end
	end

end
#=begin
d = Day.new(DateTime.now-6, DateTime.now+5, DateTime.now)
b = Block.new(DateTime.now.to_time - 7*60**2, DateTime.now.to_time - 6*60**2)

 

other = change_dt(DateTime.now, -4)
d = Day.new(change_dt(DateTime.now, -4), change_dt(DateTime.now, 4), DateTime.now)
puts d.insert(change_dt(DateTime.now, -2), change_dt(DateTime.now, 1), false)
puts d.insert(change_dt(DateTime.now, -1), change_dt(DateTime.now, 0), true)
#=end