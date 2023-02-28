# frozen_string_literal: true

require "rails_helper"

RSpec.describe DestroyApplicationFormJob do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(application_form) }

    let(:application_form) { build(:application_form) }

    it "calls DestroyApplicationForm" do
      expect(DestroyApplicationForm).to receive(:call).with(application_form:)

      perform
    end
  end
end
