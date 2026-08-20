# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkingDays::UpdateFurtherInformationRequestsAssessmentStartedToRequestedJob,
               type: :job do
  describe "#perform" do
    subject(:perform) do
      travel_to(wednesday_today) { described_class.new.perform }
    end

    # Friday prior to a Monday bank holiday (2023-05-01) weekend
    let(:friday_previous) { Date.new(2023, 4, 28) }

    # Wednesday after a Monday bank holiday (2023-05-01) weekend
    let(:wednesday_today) { Date.new(2023, 5, 3) }
    let(:friday_application_form) do
      create(:application_form, :submitted, submitted_at: friday_previous)
    end

    let(:assessment) { create(:assessment, started_at: friday_previous) }
    let(:further_information_request) do
      create(
        :received_further_information_request,
        assessment:,
        requested_at: wednesday_today,
      )
    end

    it "sets the working days" do
      expect { perform }.to change {
        further_information_request.reload.working_days_between_assessment_started_to_requested
      }.to(2)
    end
  end
end
