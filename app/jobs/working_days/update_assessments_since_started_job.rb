# frozen_string_literal: true

class WorkingDays::UpdateAssessmentsSinceStartedJob < ApplicationJob
  def perform
    Assessment
      .where.not(started_at: nil)
      .find_each do |assessment|
        assessment.update!(
          working_days_between_started_and_today:
            calendar.business_days_between(assessment.started_at, today),
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
