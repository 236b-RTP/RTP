json.array! @task_events do |task_event|
  json.(task_event, :id, :user_id, :item_id, :item_type, :created_at, :updated_at)
  json.item(task_event.item)
end