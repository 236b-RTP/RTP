class ChangeEventTimesToDates < ActiveRecord::Migration
  def change
    rename_column :events, :start_time, :start_date
    rename_column :events, :end_time, :end_date
  end
end
