# frozen_string_literal: true

require "rails_helper"

RSpec.describe RegionHelper do
  describe "#region_certificate_phrase" do
    subject(:phrase) { region_certificate_phrase(region) }

    let(:region) { build(:region, country: build(:country, code: "FR")) }

    it do
      is_expected.to eq(
        "a <span lang=\"FR\">Letter of Professional Standing</span>",
      )
    end

    context "with custom value" do
      before { region.teaching_authority_certificate = "certificate" }

      it { is_expected.to eq("a <span lang=\"FR\">certificate</span>") }
    end
  end
end
