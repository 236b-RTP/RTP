# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140401015055) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "preferences", force: true do |t|
    t.integer  "user_id"
    t.string   "profile_type"
    t.time     "start_time"
    t.time     "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preferences", ["user_id"], name: "index_preferences_on_user_id", using: :btree

  create_table "task_events", force: true do |t|
    t.integer  "user_id"
    t.integer  "item_id"
    t.string   "item_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "task_events", ["user_id"], name: "index_task_events_on_user_id", using: :btree

  create_table "tasks", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "tag_name"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "due_date"
    t.integer  "priority"
    t.integer  "difficulty"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tag_color"
    t.integer  "duration"
  end

  create_table "user_sessions", force: true do |t|
    t.integer  "user_id"
    t.string   "key"
    t.datetime "accessed_at"
    t.datetime "revoked_at"
    t.string   "ip"
    t.string   "user_agent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_sessions", ["key"], name: "index_user_sessions_on_key", unique: true, using: :btree
  add_index "user_sessions", ["user_id"], name: "index_user_sessions_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
