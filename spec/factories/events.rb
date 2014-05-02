FactoryGirl.define do
  factory :event do
    sequence(:title) { |n| "Event #{n}" }
    description "I am an event"
    start_date { DateTime.now }
    end_date { DateTime.now + 1.hour }
  end
end