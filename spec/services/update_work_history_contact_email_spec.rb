# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateWorkHistoryContactEmail do
  let(:application_form) { create(:application_form, :submitted) }
  let(:old_email_address) { "old@example.com" }
  let(:new_email_address) { "new@example.com" }

  subject(:call) do
    described_class.call(
      application_form:,
      old_email_address:,
      new_email_address:,
    )
  end

  describe "with no work history" do
    it "doesn't raise an error" do
      expect { call }.to_not raise_error
    end
  end

  describe "with one work history" do
    let!(:work_history) do
      create(:work_history, application_form:, contact_email: old_email_address)
    end

    it "changes the contact email" do
      expect { call }.to change { work_history.reload.contact_email }.to(
        new_email_address,
      )
    end

    it "changes the canonical contact email" do
      expect { call }.to change {
        work_history.reload.canonical_contact_email
      }.to(new_email_address)
    end

    it "doesn't send any emails" do
      expect { call }.to_not have_enqueued_mail(
        RefereeMailer,
        :reference_requested,
      )
    end
  end

  describe "with multiple work histories" do
    let!(:work_history) do
      create(:work_history, application_form:, contact_email: old_email_address)
    end
    let!(:work_history_other) do
      create(
        :work_history,
        application_form:,
        contact_email: "different@example.com",
      )
    end

    it "changes the contact email" do
      expect { call }.to change { work_history.reload.contact_email }.to(
        new_email_address,
      )
    end

    it "changes the canonical contact email" do
      expect { call }.to change {
        work_history.reload.canonical_contact_email
      }.to(new_email_address)
    end

    it "doesn't change the other contact email" do
      expect { call }.to_not(change { work_history_other.reload.contact_email })
    end

    it "doesn't change the other canonical contact email" do
      expect { call }.to_not(
        change { work_history_other.reload.canonical_contact_email },
      )
    end

    it "doesn't send any emails" do
      expect { call }.to_not have_enqueued_mail(
        RefereeMailer,
        :reference_requested,
      )
    end
  end

  describe "when references already sent out" do
    before do
      work_history =
        create(
          :work_history,
          application_form:,
          contact_email: old_email_address,
        )
      create(:reference_request, work_history:)
    end

    it "sends an email" do
      expect { call }.to have_enqueued_mail(RefereeMailer, :reference_requested)
    end
  end
end
