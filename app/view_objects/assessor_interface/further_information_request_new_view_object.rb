# frozen_string_literal: true

class AssessorInterface::FurtherInformationRequestNewViewObject
  def initialize(params:)
    @params = params
  end

  def further_information_request
    @further_information_request ||=
      assessment.further_information_requests.build(
        items:
          FurtherInformationRequestItemsFactory.call(
            assessment_sections: assessment.sections,
          ),
      )
  end

  def grouped_review_items_by_assessment_section
    items_by_assessment_section.map do |assessment_section, items|
      {
        heading:
          I18n.t(
            assessment_section.key,
            scope: %i[
              assessor_interface
              further_information_requests
              edit
              assessment_section
            ],
          ),
        items: review_items(items),
      }
    end
  end

  private

  attr_reader :params

  def assessment
    @assessment ||= Assessment.find(params[:assessment_id])
  end

  def items_by_assessment_section
    @items_by_assessment_section ||=
      FurtherInformationRequestItemsByAssessmentSection.call(
        further_information_request:,
      )
  end

  def item_heading(item)
    content =
      I18n.t(
        item.failure_reason_key,
        scope: %i[
          assessor_interface
          assessment_sections
          failure_reasons
          as_statement
        ],
      )

    if item.work_history_contact?
      content.gsub(".", " for #{item.work_history.school_name}.")
    else
      content
    end
  end

  def review_items(items)
    items
      .sort_by(&:failure_reason_key)
      .map do |item|
        {
          heading: item_heading(item),
          feedback: item.failure_reason_assessor_feedback,
        }.compact
      end
  end
end
