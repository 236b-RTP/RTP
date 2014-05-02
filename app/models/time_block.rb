class TimeBlock
  attr_accessor :t, :item

  def initialize(start, stop, is_task, item)
    @t = { :begin => start, :end => stop }
    @is_task = is_task
    @item = item
  end

  def is_task?
    @is_task
  end
end
