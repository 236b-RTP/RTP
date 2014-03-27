class Block
	attr_accessor :t
	def initialize (start, stop)
		@t = {:begin start, :end stop}
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
			busy ||= time.t[:begin].between?{spot.t[:begin], spot.t[:end]}
			busy ||= time.t[:end].between?{spot.t[:begin], spot.t[:end]}
			#check spot isnt between the time
			busy ||= spot.t[:begin].between?{time.t[:begin], time.t[:end]}
			busy ||= spot.t[:end].between?{time.t[:begin], time.t[:end]}

		end
		return busy
	end

	def insert (time)

		if !busy(time) && time.class == Block
			@filled << time
			return true
		else
			return false
		end
	end

end

