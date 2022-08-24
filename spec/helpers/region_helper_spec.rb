# frozen_string_literal: true

require "rails_helper"

RSpec.describe RegionHelper do
  describe "#region_certificate_phrase" do
    subject(:phrase) { region_certificate_phrase(region) }

    let(:region) { build(:region, country: build(:country, code: "FR")) }

    it { is_expected.to eq("a <span lang=\"FR\">certificate</span>") }

    context "with a region certificate" do
      before { region.teaching_authority_certificate = "region certificate" }

      it { is_expected.to eq("a <span lang=\"FR\">region certificate</span>") }
    end

    context "with a country certificate" do
      before do
        region.country.teaching_authority_certificate = "country certificate"
      end

      it { is_expected.to eq("a <span lang=\"FR\">country certificate</span>") }
    end

    context "with a region and country certificate" do
      before do
        region.teaching_authority_certificate = "region certificate"
        region.country.teaching_authority_certificate = "country certificate"
      end

      it { is_expected.to eq("a <span lang=\"FR\">region certificate</span>") }
    end
  end
end
