# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateDQTTRNRequestJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(application_form) }

    let(:application_form) { create(:application_form) }

    before do
      expect(CreateDQTTRNRequest).to receive(:call).with(application_form:)
    end

    it "runs without an error" do
      expect { perform }.to_not raise_error
    end
  end
end
