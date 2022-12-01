class UpdateWorkingDaysSinceSubmissionJob < ApplicationJob
  def perform
    ApplicationForm
      .where.not(submitted_at: nil)
      .find_each do |application_form|
        working_days_since_submission =
          calendar.business_days_between(application_form.submitted_at, today)
        application_form.update!(working_days_since_submission:)
      end
  end

  private

  def calendar
    @calendar ||= Business::Calendar.load("england_and_wales")
  end

  def today
    @today ||= Time.zone.now
  end
end
