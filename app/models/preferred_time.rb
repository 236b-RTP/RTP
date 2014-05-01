require 'time_utilities'

class PreferredTime
  attr_accessor :pref, :time

  def initialize(pref, hour, morning)
    @pref = pref
    @time = change_dt(morning.to_datetime, hour)
  end

  def <=> (another)
    @pref <=> another.pref
  end
  # can subtract from arrays using this
  def eql?(other)
    [@pref, @time].eql? [other.pref, other.time]
  end

  def hash
     [@pref, @time].hash
  end

  class << self
    def week_preferences(preference)
      today = DateTime.now
      day = preference.end_time.hour - preference.start_time.hour

      Array.new(7) { |d| Array.new(day) {|i| prefh(i, preference.profile_type, day, change_dt(make_date(today.wday, d), preference.start_time.hour)) } }
    end

    def prefh(hour, profile_type, day, rise)
      if profile_type == 'early'
        if hour < day / 3
          PreferredTime.new(10, hour, rise)
        elsif hour >= day / 3 && hour < (day / 3) * 2
          PreferredTime.new(7, hour, rise)
        elsif hour >= (day / 3) * 2
          PreferredTime.new(4, hour, rise)
        end
      elsif profile_type == 'late'
        if hour < day / 3
          PreferredTime.new(4, hour, rise)
        elsif hour >= day / 3 && hour < (day / 3) * 2
          PreferredTime.new(7, hour, rise)
        elsif hour >= (day / 3) * 2
          PreferredTime.new(10, hour, rise)
        end
      elsif profile_type == 'mix'
        if hour < day/3
          PreferredTime.new(7, hour, rise)
        elsif hour >= day / 3 && hour < (day / 3) * 2
          PreferredTime.new(10, hour, rise)
        elsif hour >= (day / 3) * 2
          PreferredTime.new(7, hour, rise)
        end
      end
    end
  end
end