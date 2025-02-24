# frozen_string_literal: true

require "rails_helper"

RSpec.describe CountryOfIssueForPassport do
  describe ".to_name" do
    subject(:to_name) { described_class.to_name(code) }

    context "with a nil country code" do
      let(:code) { nil }

      it { is_expected.to be_nil }
    end

    context "with a blank country code" do
      let(:code) { "" }

      it { is_expected.to be_nil }
    end

    context "with a valid alpha-3 country code" do
      let(:code) { "USA" }

      it { is_expected.to eq("United States") }
    end

    context "with an invalid alpha-3 country code" do
      let(:code) { "MMM" }

      it { is_expected.to be_nil }
    end
  end
end
