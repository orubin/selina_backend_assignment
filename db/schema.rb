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

ActiveRecord::Schema.define(version: 2018_09_16_120100) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "available_rooms", force: :cascade do |t|
    t.integer "location_id", null: false
    t.string "name", null: false
    t.integer "room_type", null: false
    t.integer "room_id", null: false
    t.integer "guests_amount", null: false
    t.float "price_per_night", null: false
    t.boolean "occupied", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id", "room_type"], name: "index_available_rooms_on_location_id_and_room_type"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name", null: false
    t.string "country", null: false
    t.float "latitude", null: false
    t.float "longitude", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.integer "location_id", null: false
    t.integer "room_type"
    t.integer "guests_amount", null: false
    t.integer "user_id", null: false
    t.string "status"
    t.datetime "booking_start"
    t.datetime "booking_end"
    t.jsonb "special_requests", default: "{}", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "user_id_idx"
  end

  create_table "reserved_dorm_rooms", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "reserved_room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_reserved_dorm_rooms_on_order_id"
  end

  create_table "reserved_rooms", force: :cascade do |t|
    t.integer "location_id", null: false
    t.integer "order_id", null: false
    t.integer "room_id", null: false
    t.integer "room_type", null: false
    t.datetime "date", null: false
    t.integer "guests_amount", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id", "room_id", "date"], name: "index_reserved_rooms_on_location_id_and_room_id_and_date", unique: true
  end

end
