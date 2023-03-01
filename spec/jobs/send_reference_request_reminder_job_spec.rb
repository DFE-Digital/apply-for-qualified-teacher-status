# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendReferenceRequestReminderJob do
  describe "#perform" do
    subject { described_class.new.perform(reference_request:) }

    let(:reference_request) { build(:reference_request) }

    it "calls the ReferenceRequestReminder" do
      expect(ReferenceRequestReminder).to receive(:call).with(
        reference_request:,
      )
      subject
    end
  end
end
