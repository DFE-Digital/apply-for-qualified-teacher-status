# frozen_string_literal: true

require "rails_helper"

RSpec.describe DQT::RecognitionRoute do
  describe "#for_code" do
    subject(:recognition_route) do
      described_class.for_country_code(country_code, under_old_regulations:)
    end

    let(:under_old_regulations) { nil }

    context "with Scotland" do
      let(:country_code) { "GB-SCT" }
      it { is_expected.to eq("Scotland") }
    end

    context "with Northern Ireland" do
      let(:country_code) { "GB-NIR" }
      it { is_expected.to eq("NorthernIreland") }
    end

    context "under the new regulations" do
      let(:under_old_regulations) { false }

      (Country::CODES - %w[GB-SCT GB-NIR]).each do |country_code|
        context "with #{country_code}" do
          let(:country_code) { country_code }
          it { is_expected.to eq("OverseasTrainedTeachers") }
        end
      end
    end

    context "under the old regulations" do
      let(:under_old_regulations) { true }

      Country::CODES_IN_EUROPEAN_ECONOMIC_AREA.each do |country_code|
        context "with #{country_code}" do
          let(:country_code) { country_code }
          it { is_expected.to eq("EuropeanEconomicArea") }
        end
      end

      (
        Country::CODES - %w[GB-SCT GB-NIR] -
          Country::CODES_IN_EUROPEAN_ECONOMIC_AREA
      ).each do |country_code|
        context "with #{country_code}" do
          let(:country_code) { country_code }
          it { is_expected.to eq("OverseasTrainedTeachers") }
        end
      end
    end
  end
end
