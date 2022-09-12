# frozen_string_literal: true

class AssessmentFactory
  include ServicePattern

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    sections =
      [personal_information_section] +
        section_keys.map { |key| AssessmentSection.new(key:) }
    Assessment.create!(application_form:, sections:)
  end

  private

  attr_reader :application_form

  def section_keys
    %i[qualifications].tap do |keys|
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
end
