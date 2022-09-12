# frozen_string_literal: true

class AssessmentFactory
  include ServicePattern

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    sections =
      [personal_information_section, qualifications_section] +
        section_keys.map { |key| AssessmentSection.new(key:) }
    Assessment.create!(application_form:, sections:)
  end

  private

  attr_reader :application_form

  def section_keys
    [].tap do |keys|
      keys << :work_history if application_form.needs_work_history
      if application_form.needs_written_statement ||
           application_form.needs_registration_number
        keys << :professional_standing
      end
    end
  end

  def personal_information_section
    checks = [
      :identification_document_present,
      (:name_change_document_present if application_form.has_alternative_name),
      :duplicate_application,
      :applicant_already_qts
    ].compact

    failure_reasons = [
      :identification_document_expired,
      :identification_document_illegible,
      :identification_document_mismatch,
      (
        :name_change_document_illegible if application_form.has_alternative_name
      ),
      :duplicate_application,
      :applicant_already_qts
    ].compact

    AssessmentSection.new(
      key: "personal_information",
      checks:,
      failure_reasons:
    )
  end

  def qualifications_section
    checks = %i[
      qualifications_meet_level_6_or_equivalent
      teaching_qualifcations_completed_in_eligible_country
      qualified_in_mainstream_education
      has_teacher_qualification_certificate
      has_teacher_qualification_transcript
      has_university_degree_certificate
      has_university_degree_transcript
      has_additional_qualification_certificate
      has_additional_degree_transcript
    ].compact

    failure_reasons = %i[
      teaching_qualifications_from_ineligible_country
      teaching_qualifications_not_at_required_level
      not_qualified_to_teach_mainstream
      teaching_certificate_illegible
      teaching_qualification_illegible
      degree_certificate_illegible
      degree_transcript_illegible
      application_and_qualification_names_do_not_match
      teaching_hours_not_fulfilled
      qualifications_dont_support_subjects
      qualifications_dont_match_those_entered
    ].compact

    AssessmentSection.new(key: "qualifications", checks:, failure_reasons:)
  end
end
