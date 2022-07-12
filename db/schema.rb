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

ActiveRecord::Schema[7.0].define(version: 2022_07_12_142508) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "application_forms", force: :cascade do |t|
    t.string "reference", limit: 31, null: false
    t.string "status", default: "active", null: false
    t.bigint "teacher_id", null: false
    t.bigint "eligibility_check_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["eligibility_check_id"], name: "index_application_forms_on_eligibility_check_id"
    t.index ["reference"], name: "index_application_forms_on_reference", unique: true
    t.index ["status"], name: "index_application_forms_on_status"
    t.index ["teacher_id"], name: "index_application_forms_on_teacher_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "teaching_authority_address", default: "", null: false
    t.text "teaching_authority_emails", default: [], null: false, array: true
    t.text "teaching_authority_websites", default: [], null: false, array: true
    t.text "teaching_authority_certificate", default: "", null: false
    t.text "teaching_authority_other", default: "", null: false
    t.index ["code"], name: "index_countries_on_code", unique: true
  end

  create_table "eligibility_checks", force: :cascade do |t|
    t.boolean "free_of_sanctions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "teach_children"
    t.boolean "qualification"
    t.boolean "degree"
    t.string "country_code"
    t.bigint "region_id"
    t.datetime "completed_at"
    t.boolean "completed_requirements"
  end

  create_table "features", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_features_on_name", unique: true
  end

  create_table "regions", force: :cascade do |t|
    t.bigint "country_id", null: false
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status_check", default: "none", null: false
    t.string "sanction_check", default: "none", null: false
    t.text "teaching_authority_address", default: "", null: false
    t.boolean "legacy", default: true, null: false
    t.text "teaching_authority_emails", default: [], null: false, array: true
    t.text "teaching_authority_websites", default: [], null: false, array: true
    t.index ["country_id", "name"], name: "index_regions_on_country_id_and_name", unique: true
    t.index ["country_id"], name: "index_regions_on_country_id"
  end

  create_table "staff", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at", precision: nil
    t.datetime "invitation_sent_at", precision: nil
    t.datetime "invitation_accepted_at", precision: nil
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.index ["confirmation_token"], name: "index_staff_on_confirmation_token", unique: true
    t.index ["email"], name: "index_staff_on_email", unique: true
    t.index ["invitation_token"], name: "index_staff_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_staff_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_staff_on_invited_by"
    t.index ["reset_password_token"], name: "index_staff_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_staff_on_unlock_token", unique: true
  end

  create_table "teachers", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.index ["email"], name: "index_teachers_on_email", unique: true
  end

  add_foreign_key "application_forms", "eligibility_checks"
  add_foreign_key "application_forms", "teachers"
  add_foreign_key "eligibility_checks", "regions"
  add_foreign_key "regions", "countries"
end
