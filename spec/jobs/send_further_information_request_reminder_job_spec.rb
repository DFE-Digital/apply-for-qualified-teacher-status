# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendFurtherInformationRequestReminderJob do
  describe "#perform" do
    subject { described_class.new.perform(further_information_request:) }

    let(:further_information_request) { build(:further_information_request) }

    it "calls the FurtherInformationRequestReminder" do
      expect(FurtherInformationRequestReminder).to receive(:call).with(
        further_information_request:,
      )
      subject
    end
  end
end
