# frozen_string_literal: true

class FailureReasons
  DECLINABLE = %w[
    duplicate_application
    applicant_already_qts
    teaching_qualifications_from_ineligible_country
    teaching_qualifications_not_at_required_level
    not_qualified_to_teach_mainstream
    teaching_hours_not_fulfilled
    authorisation_to_teach
    teaching_qualification
    confirm_age_range_subjects
    full_professional_status
  ].freeze

  FURTHER_INFORMATIONABLE = %w[
    identification_document_expired
    identification_document_illegible
    identification_document_mismatch
    name_change_document_illegible
    applicant_already_dqt
    application_and_qualification_names_do_not_match
    qualifications_dont_match_subjects
    qualifications_dont_match_other_details
    teaching_certificate_illegible
    teaching_transcript_illegible
    degree_certificate_illegible
    degree_transcript_illegible
    satisfactory_evidence_work_history
    registration_number
    written_statement_illegible
    written_statement_recent
    qualified_to_teach
  ].freeze

  ALL = (DECLINABLE + FURTHER_INFORMATIONABLE).freeze
end
