class ChangeTaskTimesToDates < ActiveRecord::Migration
  def change
    rename_column :tasks, :start_time, :start_date
    rename_column :tasks, :end_time, :end_date
  end
end
