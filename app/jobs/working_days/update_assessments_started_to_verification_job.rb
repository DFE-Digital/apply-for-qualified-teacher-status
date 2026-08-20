# frozen_string_literal: true

class WorkingDays::UpdateAssessmentsStartedToVerificationJob < ApplicationJob
  def perform
    Assessment
      .where.not(started_at: nil)
      .where.not(verification_started_at: nil)
      .where(working_days_between_started_and_verification_started: nil)
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

  private

  def calendar
    @calendar ||=
      Business::Calendar.new(
        holidays:
          DfE::ReferenceData::BankHolidays::BANK_HOLIDAYS.all.map(&:date),
      )
  end
end
