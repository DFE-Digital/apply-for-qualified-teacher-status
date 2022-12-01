# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateWorkingDaysJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform }

    let(:tuesday_today) { Date.new(2022, 10, 4) }
    let!(:draft_application_form) { create(:application_form) }
    let!(:monday_application_form) do
      create(:application_form, :submitted, submitted_at: Date.new(2022, 10, 3))
    end
    let!(:friday_application_form) do
      create(:application_form, :submitted, submitted_at: Date.new(2022, 9, 30))
    end

    before { travel_to(tuesday_today) { perform } }

    it "ignores draft application forms" do
      expect(
        draft_application_form.reload.working_days_since_submission,
      ).to be_nil
    end

    it "sets the working days for monday" do
      expect(
        monday_application_form.reload.working_days_since_submission,
      ).to eq(1)
    end

    it "sets the working days for friday" do
      expect(
        friday_application_form.reload.working_days_since_submission,
      ).to eq(2)
    end
  end
end
