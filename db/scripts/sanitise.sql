-- ActiveStorage

DELETE FROM "active_storage_attachments";
DELETE FROM "active_storage_blobs";
DELETE FROM "active_storage_variant_records";

-- ApplicationForm

UPDATE "application_forms"
SET
  given_names = 'Applicant',
  family_name = concat('Id-', id),
  date_of_birth = '2000-01-01',
  alternative_given_names = '',
  alternative_family_name = '',
  passport_expiry_date = CASE WHEN passport_expiry_date IS NULL THEN NULL ELSE '2032-01-01' END;,
  trs_match = '{}',
  registration_number = '';

-- AssessmentSectionFailureReason

UPDATE "selected_failure_reasons"
SET
  assessor_feedback = CASE WHEN assessor_feedback IS NULL THEN NULL ELSE '[sanitised]' END;

-- AssessmentSection
-- no update required

-- Assessment
UPDATE "assessments"
SET
  recommendation_assessor_note = CASE WHEN recommendation_assessor_note IS NULL THEN NULL ELSE '[sanitised]' END,
  age_range_note = CASE WHEN age_range_note IS NULL THEN NULL ELSE '[sanitised]' END,
  qualifications_assessor_note = CASE WHEN qualifications_assessor_note IS NULL THEN NULL ELSE '[sanitised]' END,
  subjects_note = CASE WHEN subjects_note IS NULL THEN NULL ELSE '[sanitised]' END;

-- ConsentRequest
UPDATE "consent_requests"
SET
  verify_note = CASE WHEN verify_note IS NULL THEN NULL ELSE '[sanitised]' END,
  review_note = CASE WHEN review_note IS NULL THEN NULL ELSE '[sanitised]' END;

-- Countries
-- no update required

-- Documents
-- no update required

-- TRSTRNRequest
-- clear these as the scheduled jobs might run against them
DELETE FROM "trs_trn_requests";

-- EligibilityCheck
-- no update required

-- Features
-- make sure the service open flag defaults to off
UPDATE "feature_flags_features"
  SET active = false
  WHERE name like 'service_open';

-- FurtherInformationRequestItem
UPDATE "further_information_request_items"
SET
  failure_reason_assessor_feedback = CASE WHEN failure_reason_assessor_feedback IS NULL THEN NULL ELSE '[sanitised]' END,
  response = CASE WHEN response IS NULL THEN NULL ELSE '[sanitised]' END,
  contact_email = CASE WHEN contact_email IS NULL THEN NULL ELSE 'sanitised@example.com' END,
  contact_name = CASE WHEN contact_name IS NULL THEN NULL ELSE '[sanitised]' END;

-- FurtherInformationRequest
UPDATE "further_information_requests"
SET
  failure_assessor_note = CASE WHEN failure_assessor_note IS NULL THEN NULL ELSE '[sanitised]' END,
  review_note = CASE WHEN review_note IS NULL THEN NULL ELSE '[sanitised]' END;

-- MailDeliveryFailure
DELETE FROM "mail_delivery_failures";

-- Note
UPDATE "notes"
SET
  text = CASE WHEN text IS NULL THEN NULL ELSE '[sanitised]' END;

-- ProfessionalStandingRequests
UPDATE "professional_standing_requests"
SET
  location_note = CASE WHEN location_note IS NULL THEN NULL ELSE '[sanitised]' END,
  review_note = CASE WHEN review_note IS NULL THEN NULL ELSE '[sanitised]' END,
  verify_note = CASE WHEN verify_note IS NULL THEN NULL ELSE '[sanitised]' END;

-- Qualification
UPDATE "qualifications"
SET
  title = '[sanitised]',
  institution_name = '[sanitised]',
  start_date = '01/01/2001',
  complete_date = '01/01/2002',
  certificate_date = '01/01/2002';

-- QualificationRequest
UPDATE "qualification_requests"
SET
  review_note = CASE WHEN review_note IS NULL THEN NULL ELSE '[sanitised]' END,
  verify_note = CASE WHEN verify_note IS NULL THEN NULL ELSE '[sanitised]' END;

-- Region
-- no update required

-- ReferenceRequest
UPDATE "reference_requests"
SET
  additional_information_response = CASE WHEN additional_information_response IS NULL THEN NULL ELSE '[sanitised]' END,
  children_comment = CASE WHEN children_comment IS NULL THEN NULL ELSE '[sanitised]' END,
  contact_comment = CASE WHEN contact_comment IS NULL THEN NULL ELSE '[sanitised]' END,
  dates_comment = CASE WHEN dates_comment IS NULL THEN NULL ELSE '[sanitised]' END,
  hours_comment = CASE WHEN hours_comment IS NULL THEN NULL ELSE '[sanitised]' END,
  lessons_comment = CASE WHEN lessons_comment IS NULL THEN NULL ELSE '[sanitised]' END,
  misconduct_comment = CASE WHEN misconduct_comment IS NULL THEN NULL ELSE '[sanitised]' END,
  reports_comment = CASE WHEN reports_comment IS NULL THEN NULL ELSE '[sanitised]' END,
  review_note = CASE WHEN review_note IS NULL THEN NULL ELSE '[sanitised]' END,
  satisfied_comment = CASE WHEN satisfied_comment IS NULL THEN NULL ELSE '[sanitised]' END,
  verify_note = CASE WHEN verify_note IS NULL THEN NULL ELSE '[sanitised]' END,
  slug = CASE WHEN slug IS NULL THEN NULL ELSE concat('slug-', id) END;

-- ReminderEmail
-- no update required

-- Session
DELETE FROM "sessions";

-- Staff
DELETE FROM "staff";

-- SuitabilityRecord

UPDATE "suitability_records"
SET
    date_of_birth = '2000-01-01',
    note = '[sanitised]',
    archive_note = CASE WHEN archive_note = '' THEN '' ELSE '[sanitised]' END;

UPDATE "suitability_record_emails"
SET
    value = CASE WHEN value IS NULL THEN NULL ELSE CONCAT('teacher', id, '@example.com') END,
    canonical = CASE WHEN canonical IS NULL THEN NULL ELSE CONCAT('teacher', id, '@example.com') END;

UPDATE "suitability_record_names"
SET
    value = CONCAT('Applicant ', id);

-- Teacher
UPDATE "teachers"
SET
  email = CASE WHEN email IS NULL THEN NULL ELSE CONCAT('teacher', id, '@example.com') END,
  canonical_email = CASE WHEN email IS NULL THEN NULL ELSE CONCAT('teacher', id, '@example.com') END,
  gov_one_email = CASE WHEN email IS NULL THEN NULL ELSE CONCAT('teacher', id, '@example.com') END,
  email_domain = CASE WHEN email IS NULL THEN NULL ELSE '@example.com' END,
  access_your_teaching_qualifications_url = CASE WHEN access_your_teaching_qualifications_url IS NULL THEN NULL ELSE '[sanitised]' END,
  current_sign_in_ip = '0.0.0.0',
  last_sign_in_ip = '0.0.0.0';

-- TimelineEvent
UPDATE "timeline_events"
SET
  annotation = CASE WHEN annotation IS NULL THEN NULL ELSE '[sanitised]' END,
  age_range_note = CASE WHEN age_range_note IS NULL THEN NULL ELSE '[sanitised]' END,
  new_value = CASE WHEN new_value IS NULL THEN NULL ELSE '[sanitised]' END,
  old_value = CASE WHEN old_value IS NULL THEN NULL ELSE '[sanitised]' END,
  note_text = CASE WHEN note_text IS NULL THEN NULL ELSE '[sanitised]' END,
  subjects_note = CASE WHEN subjects_note IS NULL THEN NULL ELSE '[sanitised]' END;

-- Uploads
UPDATE "uploads"
SET
  filename = CASE WHEN filename IS NULL THEN NULL ELSE '[sanitised]' END;

-- WorkHistory
UPDATE "work_histories"
SET
  school_name = '[sanitised]',
  address_line1 = CASE WHEN address_line1 IS NULL THEN NULL ELSE '[sanitised]' END,
  address_line2 = CASE WHEN address_line2 IS NULL THEN NULL ELSE '[sanitised]' END,
  city  = '[sanitised]',
  job  = '[sanitised]',
  school_website  = CASE WHEN school_website IS NULL THEN NULL ELSE '[sanitised]' END,
  contact_email  = 'sanitised@example.com',
  canonical_contact_email  = 'sanitised@example.com',
  contact_name  = '[sanitised]';
