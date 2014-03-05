class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
      t.references :user, index: true
      t.string :profile_type
      t.time :start_time
      t.time :end_time

      t.timestamps
    end
  end
end
