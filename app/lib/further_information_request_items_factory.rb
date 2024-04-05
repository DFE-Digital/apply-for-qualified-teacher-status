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
    assessment_section.selected_failure_reasons.flat_map do |failure_reason|
      build_further_information_request_item(
        failure_reason.key,
        failure_reason.assessor_feedback,
        failure_reason.work_histories,
      )
    end
  end

  def build_further_information_request_item(
    failure_reason_key,
    failure_reason_assessor_feedback,
    failure_reason_work_histories
  )
    if (
         document_type =
           FailureReasons.further_information_request_document_type(
             failure_reason_key,
           )
       ).present?
      [
        FurtherInformationRequestItem.new(
          information_type: :document,
          failure_reason_key:,
          failure_reason_assessor_feedback:,
          document: Document.new(document_type:),
        ),
      ]
    elsif FailureReasons.chooses_work_history?(failure_reason_key)
      failure_reason_work_histories.map do |work_history|
        FurtherInformationRequestItem.new(
          information_type: :work_history_contact,
          failure_reason_key:,
          failure_reason_assessor_feedback:,
          work_history:,
        )
      end
    else
      [
        FurtherInformationRequestItem.new(
          information_type: :text,
          failure_reason_key:,
          failure_reason_assessor_feedback:,
        ),
      ]
    end
  end
end
