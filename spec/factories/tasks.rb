FactoryGirl.define do
  factory :task do
    sequence(:title) { |n| "Task #{n}" }
    description "I am a task"
    tag_name "task"
    tag_color "#0000ff"
    due_date { DateTime.now + 1.day }
    priority 1
    difficulty 1
    duration 60
    completed false

    task_event
  end

  factory :completed_task, parent: :task do
    completed true
  end
end