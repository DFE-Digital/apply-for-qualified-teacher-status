require "spec_helper"

RSpec.describe DqtCountryCode do
  describe "#for_code" do
    subject(:dqt_code) { described_class.for_code(code) }

    let(:code) { "US" }

    it { is_expected.to eq("US") }

    context "with Cyprus" do
      let(:code) { "CY" }

      it { is_expected.to eq("XC") }
    end

    context "with Antarctica" do
      let(:code) { "AQ" }

      it { is_expected.to eq("XX") }
    end

    context "with British Antarctic Territory" do
      let(:code) { "BAT" }

      it { is_expected.to eq("XX") }
    end

    context "with British Indian Ocean Territory" do
      let(:code) { "IO" }

      it { is_expected.to eq("XX") }
    end

    context "with French Southern Territories" do
      let(:code) { "TF" }

      it { is_expected.to eq("XX") }
    end

    context "with Heard Island and McDonald Islands" do
      let(:code) { "HM" }

      it { is_expected.to eq("XX") }
    end
  end
end
