# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExpireFurtherInformationRequestJob do
  describe "#perform" do
    subject { described_class.new.perform(further_information_request:) }

    let(:further_information_request) { build(:further_information_request) }

    it "calls the FurtherInformationRequestExpirer" do
      expect(ExpireRequestable).to receive(:call).with(
        requestable: further_information_request,
      )
      subject
    end
  end
end
