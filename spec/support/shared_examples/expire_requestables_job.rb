# frozen_string_literal: true

RSpec.shared_examples "a expire requestables job" do |requestable|
  describe "#perform" do
    subject { described_class.new.perform }

    let!(:requested_requestable) { create(requestable, :requested) }
    let!(:received_requestable) { create(requestable, :received) }
    let!(:expired_requestable) { create(requestable, :expired) }

    it "enqueues a job for each 'requested' #{requestable}s" do
      expect(ExpireRequestableJob).to receive(:perform_later).with(
        requestable: requested_requestable,
      )
      subject
    end

    it "doesn't enqueue a job for 'received' #{requestable}s" do
      expect(ExpireRequestableJob).not_to receive(:perform_later).with(
        requestable: received_requestable,
      )
      subject
    end

    it "doesn't enqueue a job for 'expired' #{requestable}s" do
      expect(ExpireRequestableJob).not_to receive(:perform_later).with(
        requestable: expired_requestable,
      )
      subject
    end
  end
end
