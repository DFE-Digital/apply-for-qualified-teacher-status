# frozen_string_literal: true

class AssessAssessmentSection
  include ServicePattern

  def initialize(
    assessment_section:,
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
      selected_keys = selected_failure_reasons.keys

      assessment_section
        .selected_failure_reasons
        .where.not(key: selected_keys)
        .destroy_all

      selected_failure_reasons.each do |key, assessor_feedback|
        failure_reason =
          assessment_section.selected_failure_reasons.find_or_initialize_by(
            key:,
          )
        failure_reason.update!(assessor_feedback: assessor_feedback[:notes])
        next unless assessor_feedback[:work_histories]
        failure_reason.update!(
          work_histories: assessor_feedback[:work_histories],
        )
      end

      unless assessment_section.update(passed:, assessed_at: Time.zone.now)
        next false
      end

      update_application_form_assessor
      create_timeline_event(old_status:)
      update_assessment_started_at
      update_application_form_state

      true
    end
  end

  private

  attr_reader :assessment_section, :user, :passed, :selected_failure_reasons

  delegate :assessment, to: :assessment_section
  delegate :application_form, to: :assessment

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
    new_status = assessment_section.status
    return if old_status == new_status

    CreateTimelineEvent.call(
      "assessment_section_recorded",
      application_form:,
      user:,
      assessment_section:,
      old_value: old_status,
      new_value: new_status,
    )
  end

  def update_assessment_started_at
    return if assessment.started_at
    assessment.update!(started_at: Time.zone.now)
  end

  def update_application_form_state
    ApplicationFormStatusUpdater.call(application_form:, user:)
  end
end
