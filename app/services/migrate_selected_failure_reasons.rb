# frozen_string_literal: true

class MigrateSelectedFailureReasons
  include ServicePattern

  def initialize(assessment_section:)
    @assessment_section = assessment_section
  end

  def call
    assessment_section.selected_failure_reasons.each do |key, assessor_feedback|
      if assessment_section.assessment_section_failure_reasons.exists?(key:)
        next
      end

      assessment_section.assessment_section_failure_reasons.create!(
        key:,
        assessor_feedback:,
      )
    end
  end

  private

  attr_reader :assessment_section
end
