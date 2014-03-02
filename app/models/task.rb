class Task < ActiveRecord::Base
  has_one :task_event, as: :item
end
