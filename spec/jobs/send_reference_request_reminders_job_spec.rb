# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendReferenceRequestRemindersJob do
  describe "#perform" do
    subject { described_class.new.perform }

    let!(:received_reference_request) { create(:reference_request, :received) }
    let!(:requested_reference_request) do
      create(:reference_request, :requested)
    end
    let!(:expired_reference_request) { create(:reference_request, :expired) }

    it "enqueues a job for each 'requested' reference request" do
      expect(SendReferenceRequestReminderJob).to receive(:perform_later).with(
        reference_request: requested_reference_request,
      )
      subject
    end

    it "doesn't enqueue a job for 'received' reference requests" do
      expect(SendReferenceRequestReminderJob).not_to receive(
        :perform_later,
      ).with(reference_request: received_reference_request)
      subject
    end

    it "doesn't enqueue a job for 'expired' reference requests" do
      expect(SendReferenceRequestReminderJob).not_to receive(
        :perform_later,
      ).with(reference_request: received_reference_request)
      subject
    end
  end
end
