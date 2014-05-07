class AddTimeZoneToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :time_zone, :string
  end
end
