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
      .selected_failure_reasons
      .filter_map do |failure_reason, assessor_notes|
      build_further_information_request_item(failure_reason, assessor_notes)
    end
  end

  def build_further_information_request_item(failure_reason, assessor_notes)
    if TEXT_FAILURE_REASONS.include?(failure_reason)
      FurtherInformationRequestItem.new(
        information_type: :text,
        failure_reason:,
        assessor_notes:,
      )
    elsif (document_type = DOCUMENT_FAILURE_REASONS[failure_reason]).present?
      FurtherInformationRequestItem.new(
        information_type: :document,
        failure_reason:,
        assessor_notes:,
        document: Document.new(document_type:),
      )
    end
  end

  TEXT_FAILURE_REASONS = %w[
    qualifications_dont_support_subjects
    qualifications_dont_match_those_entered
    satisfactory_evidence_work_history
  ].freeze

  DOCUMENT_FAILURE_REASONS = {
    "identification_document_expired" => :identification,
    "identification_document_illegible" => :identification,
    "identification_document_mismatch" => :name_change,
    "name_change_document_illegible" => :name_change,
    "teaching_certificate_illegible" => :qualification_certificate,
    "teaching_qualification_illegible" => :qualification_transcript,
    "degree_certificate_illegible" => :qualification_certificate,
    "degree_qualification_illegible" => :qualification_transcript,
    "application_and_qualification_names_do_not_match" => :name_change,
    "written_statement_illegible" => :written_statement,
    "written_statement_recent" => :written_statement,
    "qualified_to_teach" => :written_statement,
  }.freeze
end
