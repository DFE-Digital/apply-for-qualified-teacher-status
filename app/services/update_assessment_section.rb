# frozen_string_literal: true

class UpdateAssessmentSection
  include ServicePattern

  def initialize(assessment_section:, params:)
    @assessment_section = assessment_section
    @params = params
  end

  def call
    assessment_section.update(params)
  end

  private

  attr_reader :assessment_section, :params
end
