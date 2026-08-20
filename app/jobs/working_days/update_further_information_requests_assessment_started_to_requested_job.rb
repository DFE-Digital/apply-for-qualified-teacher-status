# frozen_string_literal: true

class WorkingDays::UpdateFurtherInformationRequestsAssessmentStartedToRequestedJob < ApplicationJob
  def perform
    FurtherInformationRequest
      .joins(:assessment)
      .includes(:assessment)
      .where.not(assessment: { started_at: nil })
      .where.not(requested_at: nil)
      .find_each do |further_information_request|
        further_information_request.update!(
          working_days_between_assessment_started_to_requested:
            calendar.business_days_between(
              further_information_request.assessment.started_at,
              further_information_request.requested_at,
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
