# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReferenceRequestReminder do
  describe ".call" do
    subject { described_class.call(reference_request:) }

    shared_examples_for "an ignored reference request" do
      it "doesn't log any email" do
        expect { subject }.not_to(change { ReminderEmail.count })
      end

      it "doesn't send any email" do
        expect { subject }.to_not have_enqueued_mail(
          RefereeMailer,
          :reference_reminder,
        )
      end
    end

    shared_examples_for "a reference request that triggers a reminder" do
      it "logs an email" do
        expect { subject }.to change {
          ReminderEmail.where(requestable: reference_request).count
        }.by(1)
      end

      it "sends an email" do
        expect { subject }.to have_enqueued_mail(
          RefereeMailer,
          :reference_reminder,
        ).with(params: { reference_request:, due_date: }, args: [])
      end
    end

    shared_examples_for "a reference request with less than four weeks remaining" do
      context "when no previous reminder has been sent" do
        it_behaves_like "a reference request that triggers a reminder"
      end

      context "when a previous reminder has been sent" do
        before { reference_request.reminder_emails.create }

        it_behaves_like "an ignored reference request"
      end
    end

    shared_examples_for "a reference request with less than two weeks remaining" do
      context "when no previous reminder has been sent" do
        it_behaves_like "a reference request that triggers a reminder"
      end

      context "when a previous reminder has been sent" do
        before { reference_request.reminder_emails.create }

        it_behaves_like "an ignored reference request"
      end
    end

    shared_examples_for "a request that is allowed 6 weeks to complete" do
      context "with less than four weeks remaining" do
        let(:reference_requested_at) { (6.weeks - 27.days).ago }

        it_behaves_like "a reference request with less than four weeks remaining"
      end

      context "with less than two weeks remaining" do
        let(:reference_requested_at) { (6.weeks - 13.days).ago }

        it_behaves_like "a reference request with less than two weeks remaining"
      end
    end

    context "with a requested reference request" do
      let(:application_form) do
        create(:application_form, :submitted, :old_regs, region:)
      end
      let(:assessment) { create(:assessment, application_form:) }
      let(:region) { create(:region, :in_country, country_code: "FR") }
      let(:work_history) { reference_request.work_history }

      let(:reference_request) do
        create(
          :reference_request,
          created_at: reference_requested_at,
          assessment:,
        )
      end

      context "that allows 6 weeks to complete" do
        let(:due_date) { (reference_request.created_at + 6.weeks).to_date }

        it_behaves_like "a request that is allowed 6 weeks to complete"
      end
    end

    context "with a received reference request" do
      let(:reference_request) { create(:reference_request, :received) }

      it_behaves_like "an ignored reference request"
    end

    context "with an expired reference request" do
      let(:reference_request) { create(:reference_request, :expired) }

      it_behaves_like "an ignored reference request"
    end
  end
end
