FactoryGirl.define do
  factory :preference do
    profile_type "early"
    schedule_spread "spread"

    start_time DateTime.new(2014, 4, 29, 10, 0, 0)
    end_time DateTime.new(2014, 4, 29, 20, 0, 0)

    time_zone 'Eastern Time (US & Canada)'

    factory :condensed_preference do
      schedule_spread "condensed"
    end

    factory :night_own_preference do
      profile_type "late"
    end
  end
end