class Preference < ActiveRecord::Base
  belongs_to :user

  validates :profile_type, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
end
