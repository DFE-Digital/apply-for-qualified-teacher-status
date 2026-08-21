# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkingDays::UpdateApplicationsSinceSubmissionJob, type: :job do
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

    let(:draft_application_form) { create(:application_form) }
    let(:tuesday_application_form) do
      create(:application_form, :submitted, submitted_at: Date.new(2023, 5, 2))
    end

    it "ignores draft application forms" do
      expect { perform }.not_to(
        change do
          draft_application_form.reload.working_days_between_submitted_and_today
        end,
      )
    end

    it "sets the working days for monday" do
      expect { perform }.to change {
        tuesday_application_form.reload.working_days_between_submitted_and_today
      }.to(1)
    end

    it "sets the working days for friday" do
      expect { perform }.to change {
        friday_application_form.reload.working_days_between_submitted_and_today
      }.to(2)
    end
  end
end
