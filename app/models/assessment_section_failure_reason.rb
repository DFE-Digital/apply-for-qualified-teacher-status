# frozen_string_literal: true

# == Schema Information
#
# Table name: assessment_section_failure_reasons
#
#  id                    :bigint           not null, primary key
#  assessor_feedback     :text
#  key                   :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  assessment_section_id :bigint           not null
#
# Indexes
#
#  index_as_failure_reason_assessment_section_id  (assessment_section_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_section_id => assessment_sections.id)
#
class AssessmentSectionFailureReason < ApplicationRecord
  belongs_to :assessment_section

  ALL_FAILURE_REASONS = %i[
    identification_document_expired
    identification_document_illegible
    identification_document_mismatch
    name_change_document_illegible
    duplicate_application
    applicant_already_qts
    applicant_already_dqt
    application_and_qualification_names_do_not_match
    teaching_qualifications_from_ineligible_country
    teaching_qualifications_not_at_required_level
    teaching_hours_not_fulfilled
    not_qualified_to_teach_mainstream
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
    authorisation_to_teach
    teaching_qualification
    confirm_age_range_subjects
    qualified_to_teach
    full_professional_status
  ].freeze

  validates :key, presence: true
  validates :key, inclusion: { in: ALL_FAILURE_REASONS.map(&:to_s) }
end
