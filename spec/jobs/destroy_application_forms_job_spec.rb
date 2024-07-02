# frozen_string_literal: true

require "rails_helper"

RSpec.describe DestroyApplicationFormsJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform }

    let!(:draft_application_form) do
      create(:application_form, :draft, created_at: 6.months.ago)
    end
    let!(:awarded_application_form) do
      create(:application_form, :awarded, awarded_at: 5.years.ago)
    end
    let!(:declined_application_form) do
      create(:application_form, :declined, declined_at: 5.years.ago)
    end
    let!(:submitted_application_form) { create(:application_form, :submitted) }

    it "expires the draft application form" do
      expect { perform }.to have_enqueued_job(DestroyApplicationFormJob).with(
        draft_application_form,
      )
    end

    it "expires the awarded application form" do
      expect { perform }.to have_enqueued_job(DestroyApplicationFormJob).with(
        awarded_application_form,
      )
    end

    it "expires the declined application form" do
      expect { perform }.to have_enqueued_job(DestroyApplicationFormJob).with(
        declined_application_form,
      )
    end

    it "doesn't expire the submitted application form" do
      expect { perform }.not_to have_enqueued_job(
        DestroyApplicationFormJob,
      ).with(submitted_application_form)
    end
  end
end
