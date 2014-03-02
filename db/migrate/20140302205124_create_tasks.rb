class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.string :tag
      t.datetime :start_time
      t.datetime :end_time
      t.datetime :due_date
      t.integer :priority
      t.integer :difficulty

      t.timestamps
    end
  end
end
