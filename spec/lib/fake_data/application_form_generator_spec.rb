# frozen_string_literal: true

require "rails_helper"

RSpec.describe FakeData::ApplicationFormGenerator do
  describe "#call" do
    subject(:call) { described_class.call(region:, params:) }

    let(:region) { create(:region) }
    let(:params) { {} }

    it "doesn't raise an error" do
      expect { call }.to_not raise_error
    end
  end
end
