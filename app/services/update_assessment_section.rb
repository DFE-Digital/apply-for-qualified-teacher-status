# frozen_string_literal: true

class UpdateAssessmentSection
  include ServicePattern

  def initialize(assessment_section:, user:, params:)
    @assessment_section = assessment_section
    @params = params
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      next false unless assessment_section.update(params)

      create_timeline_event
      update_application_form_assessor
      update_application_form_state

      true
    end
  end

  private

  attr_reader :assessment_section, :user, :params

  def create_timeline_event
    TimelineEvent.create!(
      creator: user,
      event_type: :assessment_section_recorded,
      eventable: assessment_section,
      application_form:,
    )
  end

  def update_application_form_assessor
    if application_form.assessor.nil?
      AssignApplicationFormAssessor.call(
        application_form:,
        user:,
        assessor: user,
      )
    end
  end

  def update_application_form_state
    if application_form.submitted?
      ChangeApplicationFormState.call(
        application_form:,
        user:,
        new_state: "initial_assessment",
      )
    end
  end

  def application_form
    assessment_section.assessment.application_form
  end
end
