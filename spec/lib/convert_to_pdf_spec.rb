# frozen_string_literal: true

require "rails_helper"

RSpec.describe ConvertToPDF do
  let(:document) { create(:document) }

  before { create(:upload, document:) }

  describe "#call" do
    subject(:call) { described_class.call(document:, translation: false) }

    it "doesn't raise an error" do
      expect { call }.not_to raise_error
    end
  end
end
