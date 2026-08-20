# frozen_string_literal: true

class WorkingDays::UpdateAssessmentsSubmissionToPrioritisationDecisionJob < ApplicationJob
  def perform
    Assessment
      .joins(:application_form)
      .includes(:application_form)
      .where.not(application_form: { submitted_at: nil })
      .where.not(prioritisation_decision_at: nil)
      .find_each do |assessment|
        assessment.update!(
          working_days_between_submitted_and_prioritisation_decision:
            calendar.business_days_between(
              assessment.application_form.submitted_at,
              assessment.prioritisation_decision_at,
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
