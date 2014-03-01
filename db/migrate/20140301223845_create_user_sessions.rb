class CreateUserSessions < ActiveRecord::Migration
  def change
    create_table :user_sessions do |t|
      t.references :user, index: true
      t.string :key
      t.datetime :accessed_at
      t.datetime :revoked_at
      t.string :ip
      t.string :user_agent

      t.timestamps
    end
    add_index :user_sessions, :key, unique: true
  end
end
