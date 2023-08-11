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

  shared_examples "true with codes" do |codes|
    codes.each do |code|
      context "with #{code} code" do
        let(:code) { code }
        it { is_expected.to be true }
      end
    end

    (Country::CODES - codes).each do |code|
      context "with #{code} code" do
        let(:code) { code }
        it { is_expected.to be false }
      end
    end
  end

  describe "#england?" do
    subject(:england?) { described_class.england?(code) }
    include_examples "true with codes", %w[GB-ENG]
  end

  describe "#wales?" do
    subject(:wales?) { described_class.wales?(code) }
    include_examples "true with codes", %w[GB-WLS]
  end

  describe "#scotland?" do
    subject(:scotland?) { described_class.scotland?(code) }
    include_examples "true with codes", %w[GB-SCT]
  end

  describe "#northern_ireland?" do
    subject(:northern_ireland?) { described_class.northern_ireland?(code) }
    include_examples "true with codes", %w[GB-NIR]
  end

  describe "#european_economic_area?" do
    subject(:european_economic_area?) do
      described_class.european_economic_area?(code)
    end

    include_examples "true with codes", Country::CODES_IN_EUROPEAN_ECONOMIC_AREA
  end

  describe "#secondary_education_teaching_qualification_required?" do
    subject(:secondary_education_teaching_qualification_required?) do
      described_class.secondary_education_teaching_qualification_required?(code)
    end

    include_examples "true with codes",
                     Country::CODES_REQUIRING_SECONDARY_EDUCATION_TEACHING_QUALIFICATION
  end
end
