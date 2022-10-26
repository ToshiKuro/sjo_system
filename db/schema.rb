# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_08_27_044126) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "flight_data", force: :cascade do |t|
    t.integer "flight_datum_id"
    t.string "date"
    t.string "callsign"
    t.string "domestic"
    t.string "registration"
    t.string "departure"
    t.string "arrival"
    t.string "departure_spot"
    t.string "arrival_spot"
    t.string "scheduled_time_of_departure"
    t.string "scheduled_time_of_arrival"
    t.string "block_time"
    t.integer "booked_adults"
    t.integer "booked_children"
    t.integer "booked_infants"
    t.string "crew_configuration"
    t.string "block_out"
    t.string "take_off"
    t.string "estimated_time_of_arrival"
    t.string "landing"
    t.string "block_in"
    t.string "pilot_in_command"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
