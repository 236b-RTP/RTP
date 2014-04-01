require 'date'
require_relative('utility.rb')
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
			busy ||= time.t[:begin].between?(spot.t[:begin], spot.t[:end])
			busy ||= time.t[:end].between?(spot.t[:begin], spot.t[:end])
			#check spot isnt between the time
			busy ||= spot.t[:begin].between?(time.t[:begin], time.t[:end])
			busy ||= spot.t[:end].between?(time.t[:begin], time.t[:end])

		end
		return busy
	end


	#events can be at the same time need to change shit
	def insert (start, fin, if_task)
		time = Block.new(start, fin)
		if !busy(start, fin) && if_task
			@filled << time
			return true
		elsif !if_task && time.class == Block
			@filled << time
			return true
		else
			return false
		end
	end

end
=begin
d = Day.new(DateTime.now-6, DateTime.now+5, DateTime.now)
b = Block.new(DateTime.now.to_time - 7*60**2, DateTime.now.to_time - 6*60**2)
=end
 

other = change_dt(DateTime.now, -4)
d = Day.new(change_dt(DateTime.now, -4), change_dt(DateTime.now, 4), DateTime.now)
puts d.insert(change_dt(DateTime.now, -2), change_dt(DateTime.now, 1), false)
puts d.insert(change_dt(DateTime.now, -1), change_dt(DateTime.now, 0), true)