# frozen_string_literal: true

class WorkingDays::UpdateAssessmentsSubmissionToVerificationJob < ApplicationJob
  def perform
    Assessment
      .joins(:application_form)
      .includes(:application_form)
      .where.not(application_form: { submitted_at: nil })
      .where.not(verification_started_at: nil)
      .where(working_days_between_submitted_and_verification_started: nil)
      .find_each do |assessment|
        assessment.update!(
          working_days_between_submitted_and_verification_started:
            calendar.business_days_between(
              assessment.application_form.submitted_at,
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
