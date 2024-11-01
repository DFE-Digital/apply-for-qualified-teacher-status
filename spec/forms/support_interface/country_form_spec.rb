# frozen_string_literal: true

require "rails_helper"

RSpec.describe SupportInterface::CountryForm, type: :model do
  describe "#valid?" do
    let(:country) { create(:country) }

    subject(:form) do
      described_class.new(
        country:,
        eligibility_enabled: true,
        eligibility_route: "standard",
        has_regions: true,
        region_names: "Madrid",
      )
    end

    it { is_expected.to validate_presence_of(:eligibility_enabled) }

    it do
      expect(subject).to validate_inclusion_of(:eligibility_route).in_array(
        %w[expanded reduced standard],
      )
    end

    it { is_expected.to validate_presence_of(:has_regions) }

    it { is_expected.to validate_presence_of(:region_names) }

    context "when has_regions is false" do
      before { form.has_regions = false }

      it { is_expected.not_to validate_presence_of(:region_names) }
    end
  end
end
