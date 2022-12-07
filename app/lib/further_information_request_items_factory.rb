# frozen_string_literal: true

class FurtherInformationRequestItemsFactory
  include ServicePattern

  def initialize(assessment_sections:)
    @assessment_sections = assessment_sections
  end

  def call
    assessment_sections.flat_map do |assessment_section|
      build_further_information_request_items(assessment_section)
    end
  end

  private

  attr_reader :further_information_request, :assessment_sections

  def build_further_information_request_items(assessment_section)
    assessment_section
      .assessment_section_failure_reasons
      .map do |failure_reason|
      build_further_information_request_item(
        failure_reason.key,
        failure_reason.assessor_feedback,
      )
    end
  end

  def build_further_information_request_item(
    failure_reason_key,
    failure_reason_assessor_feedback
  )
    if (document_type = DOCUMENT_FAILURE_REASONS[failure_reason_key]).present?
      FurtherInformationRequestItem.new(
        information_type: :document,
        failure_reason_key:,
        failure_reason_assessor_feedback:,
        document: Document.new(document_type:),
      )
    else
      FurtherInformationRequestItem.new(
        information_type: :text,
        failure_reason_key:,
        failure_reason_assessor_feedback:,
      )
    end
  end

  DOCUMENT_FAILURE_REASONS = {
    "identification_document_expired" => :identification,
    "identification_document_illegible" => :identification,
    "identification_document_mismatch" => :name_change,
    "name_change_document_illegible" => :name_change,
    "teaching_certificate_illegible" => :qualification_certificate,
    "teaching_transcript_illegible" => :qualification_transcript,
    "degree_certificate_illegible" => :qualification_certificate,
    "degree_transcript_illegible" => :qualification_transcript,
    "qualifications_dont_match_subjects" => :qualification_document,
    "application_and_qualification_names_do_not_match" => :name_change,
    "written_statement_illegible" => :written_statement,
    "written_statement_recent" => :written_statement,
    "qualified_to_teach" => :written_statement,
  }.freeze
end
