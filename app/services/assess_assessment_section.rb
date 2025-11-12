# frozen_string_literal: true

class AssessAssessmentSection
  include ServicePattern

  def initialize(
    assessment_section,
    user:,
    passed:,
    selected_failure_reasons: {}
  )
    @assessment_section = assessment_section
    @user = user
    @passed = passed
    @selected_failure_reasons = selected_failure_reasons
  end

  def call
    old_status = assessment_section.status

    ActiveRecord::Base.transaction do
      update_selected_failure_reasons
      update_passed_and_assessed_at
      update_application_form_assessor
      create_timeline_event(old_status:)
      update_assessment_started_at
      update_application_form_state
    end
  end

  private

  attr_reader :assessment_section, :user, :passed, :selected_failure_reasons

  delegate :assessment, to: :assessment_section
  delegate :application_form, to: :assessment

  def update_selected_failure_reasons
    assessment_section.selected_failure_reasons.destroy_all

    selected_failure_reasons.each do |key, assessor_feedback|
      failure_reason =
        assessment_section.selected_failure_reasons.find_or_initialize_by(key:)

      failure_reason.update!(
        assessor_feedback: assessor_feedback[:assessor_feedback],
      )

      next unless assessor_feedback[:work_history_failure_reasons]

      failure_reason.selected_failure_reasons_work_histories.create!(
        assessor_feedback[:work_history_failure_reasons],
      )
    end
  end

  def update_passed_and_assessed_at
    assessment_section.update!(passed:, assessed_at: Time.zone.now)
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

  def create_timeline_event(old_status:)
    CreateTimelineEvent.call(
      "assessment_section_recorded",
      application_form:,
      user:,
      assessment_section:,
      old_value: old_status,
      new_value: assessment_section.status,
    )
  end

  def update_assessment_started_at
    assessment.update!(started_at: Time.zone.now) if assessment.started_at.nil?
  end

  def update_application_form_state
    ApplicationFormStatusUpdater.call(application_form:, user:)
  end
end
