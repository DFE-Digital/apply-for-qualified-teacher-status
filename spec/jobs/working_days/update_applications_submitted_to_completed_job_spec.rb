# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkingDays::UpdateApplicationsSubmittedToCompletedJob,
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

    let(:draft_application_form) { create(:application_form) }
    let(:wednesday_application_form_awarded) do
      create(
        :application_form,
        :awarded,
        submitted_at: friday_previous,
        awarded_at: wednesday_today,
      )
    end
    let(:wednesday_application_form_declined) do
      create(
        :application_form,
        :declined,
        submitted_at: friday_previous,
        declined_at: wednesday_today,
      )
    end
    let(:wednesday_application_form_withdrawn) do
      create(
        :application_form,
        :withdrawn,
        submitted_at: friday_previous,
        withdrawn_at: wednesday_today,
      )
    end

    it "ignores draft application forms" do
      expect { perform }.not_to(
        change do
          draft_application_form.reload.working_days_between_submitted_and_completed
        end,
      )
    end

    it "ignores submitted and not completed application forms" do
      expect { perform }.not_to(
        change do
          friday_application_form.reload.working_days_between_submitted_and_completed
        end,
      )
    end

    it "sets the working days for awarded" do
      expect { perform }.to change {
        wednesday_application_form_awarded.reload.working_days_between_submitted_and_completed
      }.to(2)
    end

    it "sets the working days for declined" do
      expect { perform }.to change {
        wednesday_application_form_declined.reload.working_days_between_submitted_and_completed
      }.to(2)
    end

    it "sets the working days for withdrawn" do
      expect { perform }.to change {
        wednesday_application_form_withdrawn.reload.working_days_between_submitted_and_completed
      }.to(2)
    end
  end
end
