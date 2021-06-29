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

ActiveRecord::Schema.define(version: 2021_06_24_145152) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "timescaledb"

  create_table "events", primary_key: ["event_id", "event_type", "event_source", "event_time"], force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "event_type", null: false
    t.string "event_source", null: false
    t.datetime "event_time", null: false
    t.bigint "project_id"
    t.bigint "workflow_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "data"
    t.float "session_time"
    t.string "country_name"
    t.string "country_code"
    t.string "city_name"
    t.decimal "latitude"
    t.decimal "longitude"
    t.bigint "group_id"
    t.index ["event_time"], name: "events_event_time_idx", order: :desc
    t.index ["event_type", "project_id"], name: "index_events_on_event_type_and_project_id"
    t.index ["event_type", "user_id"], name: "index_events_on_event_type_and_user_id"
  end

end
