# frozen_string_literal: true

require "rails_helper"

RSpec.describe FakeData::StaffGenerator do
  describe "#call" do
    subject(:call) { described_class.call }

    it "doesn't raise an error" do
      expect { call }.to_not raise_error
    end
  end
end
