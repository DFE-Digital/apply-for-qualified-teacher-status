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

ActiveRecord::Schema[7.1].define(version: 2024_04_02_084241) do
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
    t.boolean "teaching_authority_provides_written_statement", default: false, null: false
    t.boolean "written_statement_confirmation", default: false, null: false
    t.boolean "reduced_evidence_accepted", default: false, null: false
    t.boolean "english_language_provider_other", default: false, null: false
    t.datetime "declined_at"
    t.boolean "requires_preliminary_check", default: false, null: false
    t.boolean "written_statement_optional", default: false, null: false
    t.jsonb "dqt_match", default: {}
    t.datetime "withdrawn_at"
    t.string "action_required_by", default: "none", null: false
    t.string "stage", default: "draft", null: false
    t.string "statuses", default: ["draft"], null: false, array: true
    t.boolean "qualification_changed_work_history_duration", default: false, null: false
    t.boolean "teaching_qualification_part_of_degree"
    t.index ["action_required_by"], name: "index_application_forms_on_action_required_by"
    t.index ["assessor_id"], name: "index_application_forms_on_assessor_id"
    t.index ["english_language_provider_id"], name: "index_application_forms_on_english_language_provider_id"
    t.index ["family_name"], name: "index_application_forms_on_family_name"
    t.index ["given_names"], name: "index_application_forms_on_given_names"
    t.index ["reference"], name: "index_application_forms_on_reference", unique: true
    t.index ["region_id"], name: "index_application_forms_on_region_id"
    t.index ["reviewer_id"], name: "index_application_forms_on_reviewer_id"
    t.index ["stage"], name: "index_application_forms_on_stage"
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
    t.boolean "preliminary", default: false, null: false
    t.index ["assessment_id", "preliminary", "key"], name: "index_assessment_sections_on_assessment_id_preliminary_key", unique: true
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
    t.datetime "recommended_at"
    t.text "age_range_note", default: "", null: false
    t.text "subjects_note", default: "", null: false
    t.datetime "started_at"
    t.integer "working_days_started_to_recommendation"
    t.integer "working_days_submission_to_recommendation"
    t.integer "working_days_submission_to_started"
    t.integer "working_days_since_started"
    t.boolean "induction_required"
    t.text "recommendation_assessor_note", default: "", null: false
    t.boolean "references_verified"
    t.boolean "scotland_full_registration"
    t.boolean "unsigned_consent_document_generated", default: false, null: false
    t.text "qualifications_assessor_note", default: "", null: false
    t.index ["application_form_id"], name: "index_assessments_on_application_form_id"
  end

  create_table "consent_requests", force: :cascade do |t|
    t.datetime "received_at"
    t.datetime "requested_at"
    t.datetime "expired_at"
    t.boolean "unsigned_document_downloaded", default: false, null: false
    t.datetime "verified_at"
    t.text "verify_note", default: "", null: false
    t.boolean "verify_passed"
    t.bigint "assessment_id", null: false
    t.bigint "qualification_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "review_passed"
    t.datetime "reviewed_at"
    t.text "review_note", default: "", null: false
    t.index ["assessment_id"], name: "index_consent_requests_on_assessment_id"
    t.index ["qualification_id"], name: "index_consent_requests_on_qualification_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "other_information", default: "", null: false
    t.string "status_information", default: "", null: false
    t.string "sanction_information", default: "", null: false
    t.boolean "eligibility_enabled", default: true, null: false
    t.text "qualifications_information", default: "", null: false
    t.boolean "eligibility_skip_questions", default: false, null: false
    t.boolean "subject_limited", default: false, null: false
    t.index ["code"], name: "index_countries_on_code", unique: true
  end

  create_table "documents", force: :cascade do |t|
    t.string "document_type", null: false
    t.string "documentable_type"
    t.bigint "documentable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "completed", default: false
    t.boolean "available"
    t.index ["document_type"], name: "index_documents_on_document_type"
    t.index ["documentable_type", "documentable_id"], name: "index_documents_on_documentable"
  end

  create_table "dqt_trn_requests", force: :cascade do |t|
    t.bigint "application_form_id", null: false
    t.uuid "request_id", null: false
    t.string "state", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "potential_duplicate"
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
    t.string "work_experience"
    t.boolean "qualified_for_subject"
  end

  create_table "english_language_providers", force: :cascade do |t|
    t.string "name", null: false
    t.text "b2_level_requirement", null: false
    t.string "reference_name", null: false
    t.text "reference_hint", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "check_url"
    t.string "accepted_tests", default: "", null: false
    t.string "url", default: "", null: false
    t.string "b2_level_requirement_prefix", default: "", null: false
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
    t.bigint "work_history_id"
    t.string "contact_name"
    t.string "contact_job"
    t.string "contact_email"
    t.index ["further_information_request_id"], name: "index_fi_request_items_on_fi_request_id"
    t.index ["work_history_id"], name: "index_further_information_request_items_on_work_history_id"
  end

  create_table "further_information_requests", force: :cascade do |t|
    t.bigint "assessment_id", null: false
    t.datetime "received_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "review_passed"
    t.string "review_note", default: "", null: false
    t.integer "working_days_received_to_recommendation"
    t.integer "working_days_since_received"
    t.integer "working_days_assessment_started_to_creation"
    t.datetime "reviewed_at"
    t.datetime "requested_at"
    t.datetime "expired_at"
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

  create_table "professional_standing_requests", force: :cascade do |t|
    t.bigint "assessment_id", null: false
    t.datetime "received_at"
    t.text "location_note", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "reviewed_at"
    t.boolean "review_passed"
    t.string "review_note", default: "", null: false
    t.datetime "requested_at"
    t.datetime "expired_at"
    t.boolean "verify_passed"
    t.text "verify_note", default: "", null: false
    t.datetime "verified_at"
    t.index ["assessment_id"], name: "index_professional_standing_requests_on_assessment_id"
  end

  create_table "qualification_requests", force: :cascade do |t|
    t.bigint "assessment_id", null: false
    t.bigint "qualification_id", null: false
    t.datetime "received_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "reviewed_at"
    t.boolean "review_passed"
    t.string "review_note", default: "", null: false
    t.datetime "requested_at"
    t.datetime "expired_at"
    t.boolean "verify_passed"
    t.text "verify_note", default: "", null: false
    t.datetime "verified_at"
    t.string "consent_method", default: "unknown", null: false
    t.index ["assessment_id"], name: "index_qualification_requests_on_assessment_id"
    t.index ["qualification_id"], name: "index_qualification_requests_on_qualification_id"
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
    t.index ["application_form_id"], name: "index_qualifications_on_application_form_id"
  end

  create_table "reference_requests", force: :cascade do |t|
    t.string "slug", null: false
    t.bigint "assessment_id", null: false
    t.bigint "work_history_id", null: false
    t.datetime "received_at"
    t.boolean "dates_response"
    t.boolean "hours_response"
    t.boolean "children_response"
    t.boolean "lessons_response"
    t.boolean "reports_response"
    t.text "additional_information_response", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "review_passed"
    t.datetime "reviewed_at"
    t.boolean "contact_response"
    t.string "contact_name", default: "", null: false
    t.string "contact_job", default: "", null: false
    t.text "contact_comment", default: "", null: false
    t.text "dates_comment", default: "", null: false
    t.text "hours_comment", default: "", null: false
    t.text "children_comment", default: "", null: false
    t.text "lessons_comment", default: "", null: false
    t.text "reports_comment", default: "", null: false
    t.boolean "misconduct_response"
    t.text "misconduct_comment", default: "", null: false
    t.boolean "satisfied_response"
    t.text "satisfied_comment", default: "", null: false
    t.string "review_note", default: "", null: false
    t.datetime "requested_at"
    t.datetime "expired_at"
    t.boolean "verify_passed"
    t.text "verify_note", default: "", null: false
    t.datetime "verified_at"
    t.index ["assessment_id"], name: "index_reference_requests_on_assessment_id"
    t.index ["slug"], name: "index_reference_requests_on_slug", unique: true
    t.index ["work_history_id"], name: "index_reference_requests_on_work_history_id"
  end

  create_table "regions", force: :cascade do |t|
    t.bigint "country_id", null: false
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status_check", default: "none", null: false
    t.string "sanction_check", default: "none", null: false
    t.text "teaching_authority_address", default: "", null: false
    t.text "teaching_authority_emails", default: [], null: false, array: true
    t.text "teaching_authority_websites", default: [], null: false, array: true
    t.text "teaching_authority_name", default: "", null: false
    t.text "other_information", default: "", null: false
    t.text "teaching_authority_certificate", default: "", null: false
    t.string "teaching_authority_online_checker_url", default: "", null: false
    t.string "status_information", default: "", null: false
    t.string "sanction_information", default: "", null: false
    t.boolean "teaching_authority_provides_written_statement", default: false, null: false
    t.text "qualifications_information", default: "", null: false
    t.boolean "application_form_skip_work_history", default: false, null: false
    t.boolean "reduced_evidence_accepted", default: false, null: false
    t.boolean "teaching_authority_requires_submission_email", default: false, null: false
    t.boolean "requires_preliminary_check", default: false, null: false
    t.boolean "written_statement_optional", default: false, null: false
    t.index ["country_id", "name"], name: "index_regions_on_country_id_and_name", unique: true
    t.index ["country_id"], name: "index_regions_on_country_id"
  end

  create_table "reminder_emails", force: :cascade do |t|
    t.bigint "remindable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remindable_type", default: "", null: false
    t.string "name", default: "expiration", null: false
    t.index ["remindable_type", "remindable_id"], name: "index_reminder_emails_on_remindable_type_and_remindable_id"
  end

  create_table "selected_failure_reasons", force: :cascade do |t|
    t.bigint "assessment_section_id", null: false
    t.string "key", null: false
    t.text "assessor_feedback"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_section_id"], name: "index_as_failure_reason_assessment_section_id"
  end

  create_table "selected_failure_reasons_work_histories", id: false, force: :cascade do |t|
    t.bigint "work_history_id", null: false
    t.bigint "selected_failure_reason_id", null: false
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
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.text "name", default: "", null: false
    t.boolean "assess_permission", default: false
    t.boolean "support_console_permission", default: false, null: false
    t.string "azure_ad_uid"
    t.boolean "change_work_history_permission", default: false, null: false
    t.boolean "reverse_decision_permission", default: false, null: false
    t.boolean "withdraw_permission", default: false, null: false
    t.boolean "change_name_permission", default: false, null: false
    t.boolean "verify_permission", default: false, null: false
    t.boolean "change_email_permission", default: false, null: false
    t.index "lower((email)::text)", name: "index_staff_on_lower_email", unique: true
    t.index ["confirmation_token"], name: "index_staff_on_confirmation_token", unique: true
    t.index ["invitation_token"], name: "index_staff_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_staff_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_staff_on_invited_by"
    t.index ["reset_password_token"], name: "index_staff_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_staff_on_unlock_token", unique: true
  end

  create_table "teachers", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "trn"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.text "canonical_email", default: "", null: false
    t.string "access_your_teaching_qualifications_url"
    t.text "email_domain", default: "", null: false
    t.index "lower((email)::text)", name: "index_teacher_on_lower_email", unique: true
    t.index ["canonical_email"], name: "index_teachers_on_canonical_email"
    t.index ["uuid"], name: "index_teachers_on_uuid", unique: true
  end

  create_table "timeline_events", force: :cascade do |t|
    t.string "event_type", null: false
    t.bigint "application_form_id", null: false
    t.integer "creator_id"
    t.string "creator_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "assignee_id"
    t.bigint "assessment_section_id"
    t.bigint "note_id"
    t.string "creator_name", default: "", null: false
    t.string "mailer_action_name", default: "", null: false
    t.bigint "assessment_id"
    t.string "message_subject", default: "", null: false
    t.string "mailer_class_name", default: "", null: false
    t.string "requestable_type"
    t.bigint "requestable_id"
    t.integer "age_range_min"
    t.integer "age_range_max"
    t.text "age_range_note", default: "", null: false
    t.text "subjects", default: [], null: false, array: true
    t.text "subjects_note", default: "", null: false
    t.bigint "work_history_id"
    t.string "column_name", default: "", null: false
    t.text "old_value", default: "", null: false
    t.text "new_value", default: "", null: false
    t.text "note_text", default: "", null: false
    t.index ["application_form_id"], name: "index_timeline_events_on_application_form_id"
    t.index ["assessment_id"], name: "index_timeline_events_on_assessment_id"
    t.index ["assessment_section_id"], name: "index_timeline_events_on_assessment_section_id"
    t.index ["assignee_id"], name: "index_timeline_events_on_assignee_id"
    t.index ["note_id"], name: "index_timeline_events_on_note_id"
    t.index ["requestable_type", "requestable_id"], name: "index_timeline_events_on_requestable"
    t.index ["work_history_id"], name: "index_timeline_events_on_work_history_id"
  end

  create_table "uploads", force: :cascade do |t|
    t.bigint "document_id", null: false
    t.boolean "translation", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "malware_scan_result", default: "pending", null: false
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
    t.integer "hours_per_week"
    t.boolean "start_date_is_estimate", default: false, null: false
    t.boolean "end_date_is_estimate", default: false, null: false
    t.string "contact_job", default: "", null: false
    t.text "canonical_contact_email", default: "", null: false
    t.text "contact_email_domain", default: "", null: false
    t.index ["application_form_id"], name: "index_work_histories_on_application_form_id"
    t.index ["canonical_contact_email"], name: "index_work_histories_on_canonical_contact_email"
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
  add_foreign_key "consent_requests", "assessments"
  add_foreign_key "consent_requests", "qualifications"
  add_foreign_key "dqt_trn_requests", "application_forms"
  add_foreign_key "eligibility_checks", "regions"
  add_foreign_key "further_information_request_items", "work_histories"
  add_foreign_key "notes", "application_forms"
  add_foreign_key "notes", "staff", column: "author_id"
  add_foreign_key "professional_standing_requests", "assessments"
  add_foreign_key "qualification_requests", "assessments"
  add_foreign_key "qualification_requests", "qualifications"
  add_foreign_key "qualifications", "application_forms"
  add_foreign_key "reference_requests", "assessments"
  add_foreign_key "reference_requests", "work_histories"
  add_foreign_key "regions", "countries"
  add_foreign_key "selected_failure_reasons", "assessment_sections"
  add_foreign_key "timeline_events", "application_forms"
  add_foreign_key "timeline_events", "assessment_sections"
  add_foreign_key "timeline_events", "assessments"
  add_foreign_key "timeline_events", "notes"
  add_foreign_key "timeline_events", "staff", column: "assignee_id"
  add_foreign_key "timeline_events", "work_histories"
  add_foreign_key "uploads", "documents"
  add_foreign_key "work_histories", "application_forms"
end
