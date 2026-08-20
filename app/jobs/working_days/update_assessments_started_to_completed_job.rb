# frozen_string_literal: true

class WorkingDays::UpdateAssessmentsStartedToCompletedJob < ApplicationJob
  def perform
    Assessment
      .joins(:application_form)
      .includes(:application_form)
      .where(
        application_form: {
          stage: "completed",
        },
        working_days_between_started_and_completed: nil,
      )
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

  private

  def calendar
    @calendar ||=
      Business::Calendar.new(
        holidays:
          DfE::ReferenceData::BankHolidays::BANK_HOLIDAYS.all.map(&:date),
      )
  end
end
