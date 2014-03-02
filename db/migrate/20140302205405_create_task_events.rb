class CreateTaskEvents < ActiveRecord::Migration
  def change
    create_table :task_events do |t|
      t.references :user, index: true
      t.references :item, polymorphic: true

      t.timestamps
    end
  end
end
