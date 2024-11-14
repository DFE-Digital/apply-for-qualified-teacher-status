# frozen_string_literal: true

require "rails_helper"

RSpec.describe TRS::CountryCode do
  describe "#for_code" do
    subject(:dqt_code) { described_class.for_code(code) }

    let(:code) { "US" }

    it { is_expected.to eq("US") }

    context "with Cyprus (European Union)" do
      let(:code) { "CY" }

      it { is_expected.to eq("XA") }
    end

    context "with Cyprus (Non-European Union)" do
      let(:code) { "CY-TR" }

      it { is_expected.to eq("XB") }
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

    context "with England" do
      let(:code) { "GB-ENG" }

      it { is_expected.to eq("XF") }
    end

    context "with Wales" do
      let(:code) { "GB-WLS" }

      it { is_expected.to eq("XI") }
    end

    context "with Scotland" do
      let(:code) { "GB-SCT" }

      it { is_expected.to eq("XH") }
    end

    context "with Northern Ireland" do
      let(:code) { "GB-NIR" }

      it { is_expected.to eq("XG") }
    end
  end
end
