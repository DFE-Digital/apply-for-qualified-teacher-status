# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExpireRequestableJob do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(requestable:) }

    let(:requestable) { build(:further_information_request) }

    it "calls the ExpireRequestable" do
      expect(ExpireRequestable).to receive(:call).with(requestable:)

      perform
    end
  end
end
