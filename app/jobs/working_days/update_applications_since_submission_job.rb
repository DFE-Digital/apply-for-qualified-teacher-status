# frozen_string_literal: true

class WorkingDays::UpdateApplicationsSinceSubmissionJob < WorkingDays::BaseJob
  def perform
    ApplicationForm
      .where.not(submitted_at: nil)
      .assessable
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
end
