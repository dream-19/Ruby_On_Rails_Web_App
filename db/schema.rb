# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_03_06_152202) do
  create_table "events", charset: "utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.time "beginning_time", null: false
    t.date "beginning_date", null: false
    t.time "ending_time", null: false
    t.date "ending_date", null: false
    t.integer "max_participants", null: false
    t.string "address", null: false
    t.string "cap", null: false
    t.string "province", null: false
    t.string "state", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "subscriptions", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "event_id", null: false
    t.time "subscription_time", null: false
    t.date "subscription_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_subscriptions_on_event_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", charset: "utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.string "surname", null: false
    t.string "role", default: "normal", null: false
    t.string "email", null: false
    t.string "phone"
    t.date "date_of_birth", null: false
    t.string "address", null: false
    t.string "cap", null: false
    t.string "province", null: false
    t.string "city", null: false
    t.string "state", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "events", "users"
  add_foreign_key "subscriptions", "events"
  add_foreign_key "subscriptions", "users"
end
