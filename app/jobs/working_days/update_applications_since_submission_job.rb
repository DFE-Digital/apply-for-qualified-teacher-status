# frozen_string_literal: true

class WorkingDays::UpdateApplicationsSinceSubmissionJob < ApplicationJob
  def perform
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

  private

  def calendar
    @calendar ||=
      Business::Calendar.new(
        holidays:
          DfE::ReferenceData::BankHolidays::BANK_HOLIDAYS.all.map(&:date),
      )
  end

  def today
    @today ||= Time.zone.now
  end
end
