class AddScheduleSpreadToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :schedule_spread, :string
  end
end
