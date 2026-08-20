# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkingDays::UpdateAssessmentsSubmissionToStartedJob,
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

    let(:wednesday_started_assessment) do
      create(
        :assessment,
        started_at: wednesday_today,
        application_form: friday_application_form,
      )
    end

    it "ignores not started assessment" do
      expect { perform }.not_to(
        change do
          not_started_assessment.reload.working_days_between_submitted_and_started
        end,
      )
    end

    it "sets the working days for started assessment" do
      expect { perform }.to change {
        wednesday_started_assessment.reload.working_days_between_submitted_and_started
      }.to(2)
    end
  end
end
