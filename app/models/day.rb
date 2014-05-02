require 'time_utilities'

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
      # non-incusive some times can abut each other a to 2:00 b from 2:00 accepted
      busy ||= change_dt_sec(time.t[:begin], 1).between?(spot.t[:begin], spot.t[:end])
      busy ||= change_dt_sec(time.t[:end], -1).between?(spot.t[:begin], spot.t[:end])
      # check spot isn't between the time
      busy ||= change_dt_sec(spot.t[:begin], 1).between?(time.t[:begin], time.t[:end])
      busy ||= change_dt_sec(spot.t[:end], -1).between?(time.t[:begin], time.t[:end])
    end
    return busy
  end

  #events can be at the same time need to change stuff
  def insert(start, fin, if_task, item)
    #preftimes made by preftime builder have the date when rise time was created
    if start.between?(@wake, @sleep) && fin.between?(@wake, @sleep)
      time = TimeBlock.new(start, fin, if_task, item)
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