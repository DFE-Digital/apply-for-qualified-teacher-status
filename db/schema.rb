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

ActiveRecord::Schema[7.0].define(version: 2023_01_05_085100) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "application_forms", force: :cascade do |t|
    t.string "reference", limit: 31, null: false
    t.bigint "teacher_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "given_names", default: "", null: false
    t.text "family_name", default: "", null: false
    t.date "date_of_birth"
    t.integer "age_range_min"
    t.integer "age_range_max"
    t.boolean "has_alternative_name"
    t.text "alternative_given_names", default: "", null: false
    t.text "alternative_family_name", default: "", null: false
    t.bigint "region_id", null: false
    t.text "registration_number"
    t.boolean "has_work_history"
    t.text "subjects", default: [], null: false, array: true
    t.bigint "assessor_id"
    t.bigint "reviewer_id"
    t.string "state", default: "draft", null: false
    t.datetime "submitted_at"
    t.boolean "needs_work_history", null: false
    t.boolean "needs_written_statement", null: false
    t.boolean "needs_registration_number", null: false
    t.integer "working_days_since_submission"
    t.boolean "confirmed_no_sanctions", default: false
    t.string "personal_information_status", default: "not_started", null: false
    t.string "identification_document_status", default: "not_started", null: false
    t.string "qualifications_status", default: "not_started", null: false
    t.string "age_range_status", default: "not_started", null: false
    t.string "subjects_status", default: "not_started", null: false
    t.string "work_history_status", default: "not_started", null: false
    t.string "registration_number_status", default: "not_started", null: false
    t.string "written_statement_status", default: "not_started", null: false
    t.string "english_language_status", default: "not_started", null: false
    t.boolean "english_language_citizenship_exempt"
    t.boolean "english_language_qualification_exempt"
    t.string "english_language_proof_method"
    t.bigint "english_language_provider_id"
    t.text "english_language_provider_reference", default: "", null: false
    t.datetime "awarded_at"
    t.index ["assessor_id"], name: "index_application_forms_on_assessor_id"
    t.index ["english_language_provider_id"], name: "index_application_forms_on_english_language_provider_id"
    t.index ["family_name"], name: "index_application_forms_on_family_name"
    t.index ["given_names"], name: "index_application_forms_on_given_names"
    t.index ["reference"], name: "index_application_forms_on_reference", unique: true
    t.index ["region_id"], name: "index_application_forms_on_region_id"
    t.index ["reviewer_id"], name: "index_application_forms_on_reviewer_id"
    t.index ["state"], name: "index_application_forms_on_state"
    t.index ["teacher_id"], name: "index_application_forms_on_teacher_id"
  end

  create_table "assessment_sections", force: :cascade do |t|
    t.bigint "assessment_id", null: false
    t.string "key", null: false
    t.boolean "passed"
    t.string "checks", default: [], array: true
    t.string "failure_reasons", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_id", "key"], name: "index_assessment_sections_on_assessment_id_and_key", unique: true
    t.index ["assessment_id"], name: "index_assessment_sections_on_assessment_id"
  end

  create_table "assessments", force: :cascade do |t|
    t.bigint "application_form_id", null: false
    t.string "recommendation", default: "unknown", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "age_range_min"
    t.integer "age_range_max"
    t.text "subjects", default: [], null: false, array: true
    t.date "recommended_at"
    t.text "age_range_note", default: "", null: false
    t.text "subjects_note", default: "", null: false
    t.datetime "started_at"
    t.integer "working_days_started_to_recommendation"
    t.integer "working_days_submission_to_recommendation"
    t.integer "working_days_submission_to_started"
    t.integer "working_days_since_started"
    t.index ["application_form_id"], name: "index_assessments_on_application_form_id"
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
    t.text "teaching_authority_name", default: "", null: false
    t.boolean "teaching_authority_checks_sanctions", default: true, null: false
    t.string "teaching_authority_online_checker_url", default: "", null: false
    t.string "teaching_authority_status_information", default: "", null: false
    t.string "teaching_authority_sanction_information", default: "", null: false
    t.index ["code"], name: "index_countries_on_code", unique: true
  end

  create_table "documents", force: :cascade do |t|
    t.string "document_type", null: false
    t.string "documentable_type"
    t.bigint "documentable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_type"], name: "index_documents_on_document_type"
    t.index ["documentable_type", "documentable_id"], name: "index_documents_on_documentable"
  end

  create_table "dqt_trn_requests", force: :cascade do |t|
    t.bigint "application_form_id", null: false
    t.uuid "request_id", null: false
    t.string "state", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_form_id"], name: "index_dqt_trn_requests_on_application_form_id"
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
    t.string "work_experience"
  end

  create_table "english_language_providers", force: :cascade do |t|
    t.string "name", null: false
    t.text "b2_level_requirement", null: false
    t.string "reference_name", null: false
    t.text "reference_hint", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "feature_flags_features", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_feature_flags_features_on_name", unique: true
  end

  create_table "further_information_request_items", force: :cascade do |t|
    t.bigint "further_information_request_id"
    t.text "failure_reason_assessor_feedback"
    t.string "information_type"
    t.text "response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "failure_reason_key", default: "", null: false
    t.index ["further_information_request_id"], name: "index_fi_request_items_on_fi_request_id"
  end

  create_table "further_information_requests", force: :cascade do |t|
    t.bigint "assessment_id", null: false
    t.string "state", null: false
    t.datetime "received_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "passed"
    t.string "failure_assessor_note", default: "", null: false
    t.integer "working_days_received_to_recommendation"
    t.integer "working_days_since_received"
    t.index ["assessment_id"], name: "index_further_information_requests_on_assessment_id"
  end

  create_table "notes", force: :cascade do |t|
    t.bigint "application_form_id", null: false
    t.bigint "author_id", null: false
    t.text "text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_form_id"], name: "index_notes_on_application_form_id"
    t.index ["author_id"], name: "index_notes_on_author_id"
  end

  create_table "qualifications", force: :cascade do |t|
    t.bigint "application_form_id", null: false
    t.text "title", default: "", null: false
    t.text "institution_name", default: "", null: false
    t.text "institution_country_code", default: "", null: false
    t.date "start_date"
    t.date "complete_date"
    t.date "certificate_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "part_of_university_degree"
    t.index ["application_form_id"], name: "index_qualifications_on_application_form_id"
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
    t.text "teaching_authority_name", default: "", null: false
    t.text "teaching_authority_other", default: "", null: false
    t.boolean "application_form_enabled", default: false
    t.text "teaching_authority_certificate", default: "", null: false
    t.string "teaching_authority_online_checker_url", default: "", null: false
    t.string "teaching_authority_status_information", default: "", null: false
    t.string "teaching_authority_sanction_information", default: "", null: false
    t.index ["country_id", "name"], name: "index_regions_on_country_id_and_name", unique: true
    t.index ["country_id"], name: "index_regions_on_country_id"
  end

  create_table "reminder_emails", force: :cascade do |t|
    t.bigint "further_information_request_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["further_information_request_id"], name: "index_reminder_emails_on_further_information_request_id"
  end

  create_table "selected_failure_reasons", force: :cascade do |t|
    t.bigint "assessment_section_id", null: false
    t.string "key", null: false
    t.text "assessor_feedback"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_section_id"], name: "index_as_failure_reason_assessment_section_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
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
    t.text "name", default: "", null: false
    t.boolean "award_decline_permission", default: false
    t.boolean "support_console_permission", default: false, null: false
    t.index "lower((email)::text)", name: "index_staff_on_lower_email", unique: true
    t.index ["confirmation_token"], name: "index_staff_on_confirmation_token", unique: true
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
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "trn"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.string "secret_key"
    t.integer "otp_guesses", default: 0, null: false
    t.datetime "otp_created_at", precision: nil
    t.index "lower((email)::text)", name: "index_teacher_on_lower_email", unique: true
    t.index ["uuid"], name: "index_teachers_on_uuid", unique: true
  end

  create_table "timeline_events", force: :cascade do |t|
    t.string "event_type", null: false
    t.bigint "application_form_id", null: false
    t.string "annotation", default: "", null: false
    t.integer "creator_id"
    t.string "creator_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "assignee_id"
    t.string "old_state", default: "", null: false
    t.string "new_state", default: "", null: false
    t.bigint "assessment_section_id"
    t.bigint "note_id"
    t.bigint "further_information_request_id"
    t.string "creator_name", default: "", null: false
    t.string "mailer_action_name", default: "", null: false
    t.bigint "assessment_id"
    t.string "message_subject", default: "", null: false
    t.index ["application_form_id"], name: "index_timeline_events_on_application_form_id"
    t.index ["assessment_id"], name: "index_timeline_events_on_assessment_id"
    t.index ["assessment_section_id"], name: "index_timeline_events_on_assessment_section_id"
    t.index ["assignee_id"], name: "index_timeline_events_on_assignee_id"
    t.index ["further_information_request_id"], name: "index_timeline_events_on_further_information_request_id"
    t.index ["note_id"], name: "index_timeline_events_on_note_id"
  end

  create_table "uploads", force: :cascade do |t|
    t.bigint "document_id", null: false
    t.boolean "translation", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_id"], name: "index_uploads_on_document_id"
  end

  create_table "work_histories", force: :cascade do |t|
    t.bigint "application_form_id", null: false
    t.text "school_name", default: "", null: false
    t.text "city", default: "", null: false
    t.text "country_code", default: "", null: false
    t.text "job", default: "", null: false
    t.text "contact_email", default: "", null: false
    t.date "start_date"
    t.boolean "still_employed"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "contact_name", default: "", null: false
    t.index ["application_form_id"], name: "index_work_histories_on_application_form_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "application_forms", "english_language_providers"
  add_foreign_key "application_forms", "regions"
  add_foreign_key "application_forms", "staff", column: "assessor_id"
  add_foreign_key "application_forms", "staff", column: "reviewer_id"
  add_foreign_key "application_forms", "teachers"
  add_foreign_key "assessment_sections", "assessments"
  add_foreign_key "assessments", "application_forms"
  add_foreign_key "dqt_trn_requests", "application_forms"
  add_foreign_key "eligibility_checks", "regions"
  add_foreign_key "notes", "application_forms"
  add_foreign_key "notes", "staff", column: "author_id"
  add_foreign_key "qualifications", "application_forms"
  add_foreign_key "regions", "countries"
  add_foreign_key "reminder_emails", "further_information_requests"
  add_foreign_key "selected_failure_reasons", "assessment_sections"
  add_foreign_key "timeline_events", "application_forms"
  add_foreign_key "timeline_events", "assessment_sections"
  add_foreign_key "timeline_events", "assessments"
  add_foreign_key "timeline_events", "further_information_requests"
  add_foreign_key "timeline_events", "notes"
  add_foreign_key "timeline_events", "staff", column: "assignee_id"
  add_foreign_key "uploads", "documents"
  add_foreign_key "work_histories", "application_forms"
end
