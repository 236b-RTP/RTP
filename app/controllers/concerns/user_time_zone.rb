module UserTimeZone
  extend ActiveSupport::Concern

  def with_user_time_zone
    raise 'must be called with a block' unless block_given?
    Time.use_zone(current_user.preference.time_zone) do
      Chronic.time_class = Time.zone
      yield
    end
    Chronic.time_class = Time.zone
  end
end