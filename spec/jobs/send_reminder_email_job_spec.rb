# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendReminderEmailJob do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(remindable) }

    let(:remindable) { build(:further_information_request) }

    it "calls the FurtherInformationRequestReminder" do
      expect(SendReminderEmail).to receive(:call).with(remindable:)

      perform
    end
  end
end
