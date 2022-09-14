# frozen_string_literal: true

class UpdateAssessmentSection
  include ServicePattern

  def initialize(assessment_section:, user:, params:)
    @assessment_section = assessment_section
    @params = params
    @user = user
  end

  def call
    create_timeline_event if (result = assessment_section.update(params))
    result
  end

  private

  attr_reader :assessment_section, :user, :params

  def create_timeline_event
    TimelineEvent.create!(
      creator: user,
      event_type: :assessment_section_completed,
      eventable: assessment_section,
      application_form:
    )
  end

  def application_form
    assessment_section.assessment.application_form
  end
end
