# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ReferenceRequestViewObject do
  subject(:view_object) { described_class.new(reference_request:) }

  let(:assessment) { create(:assessment, :verify) }
  let(:application_form) { assessment.application_form }
  let(:reference_request) { create(:reference_request, assessment:) }

  describe "#can_resend_email?" do
    subject(:can_resend_email?) { view_object.can_resend_email? }

    it { is_expected.to be true }

    context "when reference request has been expired" do
      let(:reference_request) do
        create(:reference_request, assessment:, expired_at: Time.current)
      end

      it { is_expected.to be true }
    end

    context "when reference request has been received" do
      let(:reference_request) do
        create(:received_reference_request, assessment:)
      end

      it { is_expected.to be false }
    end

    context "when the assessment is in review" do
      let(:assessment) { create(:assessment, :review) }

      it { is_expected.to be false }
    end
  end

  describe "#last_sent_at_local_timestamp" do
    subject(:last_sent_at_local_timestamp) do
      view_object.last_sent_at_local_timestamp
    end

    context "when no relevant email deliveries or reminder emails have been recorded" do
      it { is_expected.to eq(reference_request.created_at) }
    end

    context "when there are email deliveries for the reference request" do
      let(:reference_request) do
        create(:reference_request, assessment:, created_at: 10.days.ago)
      end

      let!(:email_delivery_one) do
        create :email_delivery,
               application_form:,
               reference_request:,
               created_at: 10.days.ago
      end

      let!(:email_delivery_two) do
        create :email_delivery,
               application_form:,
               reference_request:,
               created_at: email_delivery_one.created_at + 5.days
      end

      it "returns the latest email delivery created_at" do
        expect(subject).to eq(email_delivery_two.created_at)
      end
    end

    context "when there are a mix of email deliveries and reminder emails" do
      let(:reference_request) do
        create(:reference_request, assessment:, created_at: 10.days.ago)
      end

      let!(:reminder_email) do
        create :reminder_email,
               remindable: reference_request,
               created_at: 2.days.ago
      end

      before do
        create :email_delivery,
               application_form:,
               reference_request:,
               created_at: 10.days.ago

        create :email_delivery,
               application_form:,
               reference_request:,
               created_at: 5.days.ago
      end

      it "returns the latest timestamp between email deliveries and reminder emails" do
        expect(subject).to eq(reminder_email.created_at)
      end
    end
  end
end
