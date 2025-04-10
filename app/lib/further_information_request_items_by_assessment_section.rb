# frozen_string_literal: true

class FurtherInformationRequestItemsByAssessmentSection
  include ServicePattern

  def initialize(further_information_request:)
    @further_information_request = further_information_request
  end

  def call
    items_grouped_by_assessment_section.sort_by do |assessment_section, _items|
      AssessmentSection.keys.keys.index(assessment_section.key)
    end
  end

  private

  attr_reader :further_information_request

  def items_grouped_by_assessment_section
    @items_grouped_by_assessment_section ||=
      further_information_request.items.group_by do |item|
        item
          .further_information_request
          .assessment
          .sections
          .includes(:selected_failure_reasons)
          .find_by(selected_failure_reasons: { key: item.failure_reason_key })
      end
  end
end
