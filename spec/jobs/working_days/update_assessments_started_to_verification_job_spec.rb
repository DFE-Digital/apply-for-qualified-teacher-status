# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkingDays::UpdateAssessmentsStartedToVerificationJob,
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

    let(:not_started_assessment) do
      create(:assessment, application_form: friday_application_form)
    end

    let(:not_started_verification_assessment) do
      create(:assessment, started_at: friday_previous)
    end

    let(:wednesday_verification_started_assessment) do
      create(
        :assessment,
        started_at: friday_previous,
        verification_started_at: wednesday_today,
      )
    end

    it "ignores not started assessment" do
      expect { perform }.not_to(
        change do
          not_started_assessment.reload.working_days_between_started_and_verification_started
        end,
      )
    end

    it "ignores not started verification assessment" do
      expect { perform }.not_to(
        change do
          not_started_verification_assessment.reload.working_days_between_started_and_verification_started
        end,
      )
    end

    it "sets the working days for started verification assessment" do
      expect { perform }.to change {
        wednesday_verification_started_assessment.reload.working_days_between_started_and_verification_started
      }.to(2)
    end
  end
end
