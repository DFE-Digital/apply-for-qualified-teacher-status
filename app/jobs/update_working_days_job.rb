# frozen_string_literal: true

class UpdateWorkingDaysJob < ApplicationJob
  def perform
    update_application_forms_working_days_since_submission
    update_assessments_started_to_recommendation
    update_assessments_submission_to_recommendation
    update_assessments_submission_to_started
    update_further_information_requests_received
  end

  private

  def calendar
    @calendar ||= Business::Calendar.load("england_and_wales")
  end

  def today
    @today ||= Time.zone.now
  end

  def update_application_forms_working_days_since_submission
    ApplicationForm
      .where.not(submitted_at: nil)
      .find_each do |application_form|
        application_form.update!(
          working_days_since_submission:
            calendar.business_days_between(
              application_form.submitted_at,
              today,
            ),
        )
      end
  end

  def update_assessments_started_to_recommendation
    Assessment
      .includes(:application_form)
      .started
      .recommended
      .find_each do |assessment|
        assessment.update!(
          working_days_started_to_recommendation:
            calendar.business_days_between(
              assessment.started_at,
              assessment.recommended_at,
            ),
        )
      end
  end

  def update_assessments_submission_to_recommendation
    Assessment
      .joins(:application_form)
      .includes(:application_form)
      .recommended
      .where.not(application_forms: { submitted_at: nil })
      .find_each do |assessment|
        assessment.update!(
          working_days_submission_to_recommendation:
            calendar.business_days_between(
              assessment.application_form.submitted_at,
              assessment.recommended_at,
            ),
        )
      end
  end

  def update_assessments_submission_to_started
    Assessment
      .joins(:application_form)
      .includes(:application_form)
      .started
      .where.not(application_forms: { submitted_at: nil })
      .find_each do |assessment|
        assessment.update!(
          working_days_submission_to_started:
            calendar.business_days_between(
              assessment.application_form.submitted_at,
              assessment.started_at,
            ),
        )
      end
  end

  def update_further_information_requests_received
    FurtherInformationRequest
      .joins(:assessment)
      .includes(:assessment)
      .received
      .merge(Assessment.recommended)
      .find_each do |further_information_request|
        further_information_request.update!(
          working_days_received_to_recommendation:
            calendar.business_days_between(
              further_information_request.received_at,
              further_information_request.assessment.recommended_at,
            ),
        )
      end
  end
end
