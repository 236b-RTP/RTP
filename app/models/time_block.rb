class TimeBlock
  attr_accessor :t, :item

  def initialize(start, stop, type, item)
  	if start.class == DateTime && stop.class == DateTime && !!type == type
    	@t = { :begin => start, :end => stop }
    	@type = type
    	@item = item
    else
    	raise ArgumentError
    end
  end

  def is_task?
    @type
  end
end
