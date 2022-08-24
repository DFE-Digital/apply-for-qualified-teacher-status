# frozen_string_literal: true

require "rails_helper"

RSpec.describe CountryCode do
  describe "#from_location" do
    subject(:from_location) { described_class.from_location(location) }

    context "with a nil location" do
      let(:location) { nil }
      it { is_expected.to eq("") }
    end

    context "with a blank location" do
      let(:location) { "" }
      it { is_expected.to eq("") }
    end

    context "with a location" do
      let(:location) { "country:US" }
      it { is_expected.to eq("US") }
    end
  end

  describe "#to_location" do
    subject(:to_location) { described_class.to_location(code) }

    context "with a nil code" do
      let(:code) { nil }
      it { is_expected.to be_nil }
    end

    context "with a blank code" do
      let(:code) { "" }
      it { is_expected.to be_nil }
    end

    context "with a code" do
      let(:code) { "US" }
      it { is_expected.to eq("country:US") }
    end
  end
end
