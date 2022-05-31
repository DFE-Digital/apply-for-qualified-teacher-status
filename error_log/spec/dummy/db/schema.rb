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

ActiveRecord::Schema[7.0].define(version: 2022_05_31_111721) do
  create_table "error_log_validation_errors", force: :cascade do |t|
    t.string "form_object", null: false
    t.json "messages", default: "{}", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["messages"], name: "index_error_log_validation_errors_on_messages"
    t.index ["record_type", "record_id"], name: "index_error_log_validation_errors_on_record"
  end

end
