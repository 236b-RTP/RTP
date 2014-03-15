class Block
	attr_accessor :t
	def initialize (start, stop)
		@t = {:begin start, :end stop}
	end
end

class Day

	def initialize(wake, sleep)
		total_seconds = sleep - wake.to_i
		@minutes = ((total_seconds % 3600) / 60).to_i
		seconds_diff = (start_time - end_time).to_i.abs
		@filled = []

		@hours = total_seconds / 3600
		
		@day = Array.new(@minuits, 0)
		@day = Array.new(@hours, 0)

	end

	def busy(time)
		busy = false
		@filled.each do |spot|
			busy ||= time.t[:begin].between{spot.t[:begin], spot.t[:end]}
			busy ||= time.t[:end].between{spot.t[:begin], spot.t[:end]}
			#check spot isnt between the time
			busy ||= spot.t[:begin].between{time.t[:begin], time.t[:end]}
			busy ||= spot.t[:end].between{time.t[:begin], time.t[:end]}

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

