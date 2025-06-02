# frozen_string_literal: true

class UpdateWorkingDaysJob < ApplicationJob
  def perform
    update_application_forms_since_submission
    update_application_forms_submitted_to_completed

    update_assessments_since_started
    update_assessments_started_to_completed
    update_assessments_submission_to_started
    update_assessment_started_to_verification
    update_assessment_submission_to_verification

    update_further_information_requests_assessment_started_to_requested
  end

  private

  def calendar
    @calendar ||= Business::Calendar.load("england_and_wales")
  end

  def today
    @today ||= Time.zone.now
  end

  def update_application_forms_since_submission
    ApplicationForm
      .where.not(submitted_at: nil)
      .find_each do |application_form|
        application_form.update!(
          working_days_between_submitted_and_today:
            calendar.business_days_between(
              application_form.submitted_at,
              today,
            ),
        )
      end
  end

  def update_application_forms_submitted_to_completed
    ApplicationForm.completed_stage.find_each do |application_form|
      application_form.update!(
        working_days_between_submitted_and_completed:
          calendar.business_days_between(
            application_form.submitted_at,
            application_form.awarded_at || application_form.declined_at ||
              application_form.withdrawn_at,
          ),
      )
    end
  end

  def update_assessments_since_started
    Assessment
      .where.not(started_at: nil)
      .find_each do |assessment|
        assessment.update!(
          working_days_between_started_and_today:
            calendar.business_days_between(assessment.started_at, today),
        )
      end
  end

  def update_assessments_started_to_completed
    Assessment
      .joins(:application_form)
      .includes(:application_form)
      .where(application_form: { stage: "completed" })
      .where.not(started_at: nil)
      .find_each do |assessment|
        application_form = assessment.application_form

        assessment.update!(
          working_days_between_started_and_completed:
            calendar.business_days_between(
              assessment.started_at,
              application_form.awarded_at || application_form.declined_at ||
                application_form.withdrawn_at,
            ),
        )
      end
  end

  def update_assessments_submission_to_started
    Assessment
      .joins(:application_form)
      .includes(:application_form)
      .where.not(application_form: { submitted_at: nil })
      .where.not(started_at: nil)
      .find_each do |assessment|
        assessment.update!(
          working_days_between_submitted_and_started:
            calendar.business_days_between(
              assessment.application_form.submitted_at,
              assessment.started_at,
            ),
        )
      end
  end

  def update_assessment_started_to_verification
    Assessment
      .where.not(started_at: nil)
      .where.not(verification_started_at: nil)
      .find_each do |assessment|
        assessment.update!(
          working_days_between_started_and_verification_started:
            calendar.business_days_between(
              assessment.started_at,
              assessment.verification_started_at,
            ),
        )
      end
  end

  def update_assessment_submission_to_verification
    Assessment
      .joins(:application_form)
      .includes(:application_form)
      .where.not(application_form: { submitted_at: nil })
      .where.not(verification_started_at: nil)
      .find_each do |assessment|
        assessment.update!(
          working_days_between_submitted_and_verification_started:
            calendar.business_days_between(
              assessment.application_form.submitted_at,
              assessment.verification_started_at,
            ),
        )
      end
  end

  def update_further_information_requests_assessment_started_to_requested
    FurtherInformationRequest
      .joins(:assessment)
      .includes(:assessment)
      .where.not(assessment: { started_at: nil })
      .where.not(requested_at: nil)
      .find_each do |further_information_request|
        further_information_request.update!(
          working_days_between_assessment_started_to_requested:
            calendar.business_days_between(
              further_information_request.assessment.started_at,
              further_information_request.requested_at,
            ),
        )
      end
  end
end
