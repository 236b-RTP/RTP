class TimeBlock
  attr_accessor :t, :item

  def initialize(start, stop, type, item)
    @t = {:begin => start, :end => stop}
    @type = type
    @item = item
  end

  def is_task?
    @type
  end
end