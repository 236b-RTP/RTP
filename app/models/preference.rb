class Preference < ActiveRecord::Base
  belongs_to :user

  validates :profile_type, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :schedule_spread, presence: true
  validates :time_zone, presence: true
end
