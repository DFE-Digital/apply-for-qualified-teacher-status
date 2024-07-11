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
  registration_number = '';

-- AssessmentSectionFailureReason

UPDATE "selected_failure_reasons"
SET
  assessor_feedback = CASE WHEN assessor_feedback IS NULL THEN NULL ELSE '[sanitised]' END;

-- AssessmentSection
-- no update required

-- Assessment
-- no update required

-- Countries
-- no update required

-- Documents
-- no update required

-- DQTTRNRequest
-- clear these as the scheduled jobs might run against them
DELETE FROM "dqt_trn_requests";

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
  response = CASE WHEN response IS NULL THEN NULL ELSE '[sanitised]' END;

-- FurtherInformationRequest
UPDATE "further_information_requests"
SET
  failure_assessor_note = CASE WHEN failure_assessor_note IS NULL THEN NULL ELSE '[sanitised]' END;

-- Note
UPDATE "notes"
SET
  text = CASE WHEN text IS NULL THEN NULL ELSE '[sanitised]' END;

-- Qualification
UPDATE "qualifications"
SET
  title = '[sanitised]',
  institution_name = '[sanitised]',
  start_date = '01/01/2001',
  complete_date = '01/01/2002',
  certificate_date = '01/01/2002';

-- Region
-- no update required

-- ReferenceRequest
-- no update required

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
  current_sign_in_ip = '0.0.0.0',
  last_sign_in_ip = '0.0.0.0';

-- TimelineEvent
UPDATE "timeline_events"
SET
  annotation = CASE WHEN annotation IS NULL THEN NULL ELSE '[sanitised]' END;

-- Uploads
-- no update required

-- WorkHistory
UPDATE "work_histories"
SET
  school_name = '[sanitised]',
  city  = '[sanitised]',
  job  = '[sanitised]',
  contact_email  = 'sanitised@example.com',
  contact_name  = '[sanitised]';
