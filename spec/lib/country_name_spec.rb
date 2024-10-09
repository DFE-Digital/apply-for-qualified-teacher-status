# frozen_string_literal: true

require "rails_helper"

RSpec.describe CountryName do
  let(:country) { create(:country, code: "US") }

  describe "#from_code" do
    subject(:name) { described_class.from_code(code, with_definite_article:) }

    let(:code) { "US" }
    let(:with_definite_article) { false }

    it { is_expected.to eq("United States") }

    context "with definite article" do
      let(:with_definite_article) { true }

      it { is_expected.to eq("the United States") }
    end
  end

  describe "#from_country" do
    subject(:name) do
      described_class.from_country(country, with_definite_article:)
    end

    let(:with_definite_article) { false }

    it { is_expected.to eq("United States") }

    context "with definite article" do
      let(:with_definite_article) { true }

      it { is_expected.to eq("the United States") }
    end
  end

  describe "#from_region" do
    subject(:name) do
      described_class.from_region(region, with_definite_article:)
    end

    let(:region) { create(:region, :national, country:) }
    let(:with_definite_article) { false }

    it { is_expected.to eq("United States") }

    context "with definite article" do
      let(:with_definite_article) { true }

      it { is_expected.to eq("the United States") }
    end

    context "with a region name" do
      before { region.update!(name: "California") }

      it { is_expected.to eq("California") }
    end
  end

  describe "#from_region_with_country" do
    subject(:name) do
      described_class.from_region_with_country(region, with_definite_article:)
    end

    let(:region) { create(:region, :national, country:) }
    let(:with_definite_article) { false }

    it { is_expected.to eq("United States") }

    context "with definite article" do
      let(:with_definite_article) { true }

      it { is_expected.to eq("the United States") }
    end

    context "with a region name" do
      before { region.update!(name: "California") }

      it { is_expected.to eq("California, United States") }
    end
  end

  describe "#from_eligibility_check" do
    subject(:name) do
      described_class.from_eligibility_check(
        eligibility_check,
        with_definite_article:,
      )
    end

    let(:eligibility_check) { create(:eligibility_check, country_code: "US") }
    let(:with_definite_article) { false }

    it { is_expected.to eq("United States") }

    context "with definite article" do
      let(:with_definite_article) { true }

      it { is_expected.to eq("the United States") }
    end

    context "with a national region" do
      before do
        eligibility_check.update!(region: create(:region, :national, country:))
      end

      it { is_expected.to eq("United States") }
    end

    context "with a named region" do
      before { eligibility_check.update!(region: create(:region, country:)) }

      it { is_expected.to eq("United States") }
    end
  end
end
