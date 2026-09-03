# frozen_string_literal: true

class WorkingDays::UpdateAssessmentsSinceStartedJob < WorkingDays::BaseJob
  def perform
    Assessment
      .where.not(started_at: nil)
      .joins(:application_form)
      .merge(ApplicationForm.assessable)
      .find_each do |assessment|
        assessment.update!(
          working_days_between_started_and_today:
            calendar.business_days_between(assessment.started_at, today),
        )
      end
  end
end
