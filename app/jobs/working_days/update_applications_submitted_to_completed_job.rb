# frozen_string_literal: true

class WorkingDays::UpdateApplicationsSubmittedToCompletedJob < ApplicationJob
  def perform
    ApplicationForm
      .completed_stage
      .where(working_days_between_submitted_and_completed: nil)
      .find_each do |application_form|
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

  private

  def calendar
    @calendar ||=
      Business::Calendar.new(
        holidays:
          DfE::ReferenceData::BankHolidays::BANK_HOLIDAYS.all.map(&:date),
      )
  end
end
