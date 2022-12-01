# frozen_string_literal: true

class UpdateWorkingDaysJob < ApplicationJob
  def perform
    update_application_forms_working_days_since_submission
  end

  private

  def calendar
    @calendar ||= Business::Calendar.load("england_and_wales")
  end

  def today
    @today ||= Time.zone.now
  end

  def update_application_forms_working_days_since_submission
    ApplicationForm.where.not(submitted_at: nil).find_each do |application_form|
      application_form.update!(
        working_days_since_submission:
          calendar.business_days_between(application_form.submitted_at, today),
      )
    end
  end
end
