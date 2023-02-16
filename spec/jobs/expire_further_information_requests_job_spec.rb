# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExpireFurtherInformationRequestsJob do
  describe "#perform" do
    subject { described_class.new.perform }

    let!(:received_fi_request) do
      create(:further_information_request, :received)
    end
    let!(:requested_fi_request) do
      create(:further_information_request, :requested)
    end
    let!(:expired_fi_request) { create(:further_information_request, :expired) }

    it "enqueues a job for each 'requested' FI request" do
      expect(ExpireRequestableJob).to receive(:perform_later).with(
        further_information_request: requested_fi_request,
      )
      subject
    end

    it "doesn't enqueue a job for 'received' FI requests" do
      expect(ExpireRequestableJob).not_to receive(:perform_later).with(
        further_information_request: received_fi_request,
      )
      subject
    end

    it "doesn't enqueue a job for 'expired' FI requests" do
      expect(ExpireRequestableJob).not_to receive(:perform_later).with(
        further_information_request: received_fi_request,
      )
      subject
    end
  end
end
