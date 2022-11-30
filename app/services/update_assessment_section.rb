# frozen_string_literal: true

class UpdateAssessmentSection
  include ServicePattern

  def initialize(assessment_section:, user:, params:)
    @assessment_section = assessment_section
    @params = params
    @user = user
  end

  def call
    old_state = assessment_section.state

    ActiveRecord::Base.transaction do
      next false unless assessment_section.update(params)

      selected_keys = params[:selected_failure_reasons].keys
      assessment_section
        .assessment_section_failure_reasons
        .where.not(key: selected_keys)
        .destroy_all

      params[:selected_failure_reasons].each do |key, assessor_feedback|
        assessment_section
          .assessment_section_failure_reasons
          .find_or_initialize_by(key:)
          .update(assessor_feedback:)
      end

      create_timeline_event(old_state:)
      update_application_form_assessor
      update_application_form_state

      true
    end
  end

  private

  attr_reader :assessment_section, :user, :params

  def create_timeline_event(old_state:)
    new_state = assessment_section.state
    return if old_state == new_state

    TimelineEvent.create!(
      creator: user,
      event_type: :assessment_section_recorded,
      assessment_section:,
      application_form:,
      old_state:,
      new_state:,
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
