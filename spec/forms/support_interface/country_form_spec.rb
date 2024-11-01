# frozen_string_literal: true

require "rails_helper"

RSpec.describe SupportInterface::CountryForm, type: :model do
  describe "#valid?" do
    subject(:form) do
      described_class.new(
        country:,
        eligibility_enabled: true,
        eligibility_route: "standard",
        has_regions: true,
        region_names: "Madrid",
      )
    end

    let(:country) { create(:country) }

    it do
      expect(subject).to validate_presence_of(
        :eligibility_enabled,
      ).with_message(
        "You must select whether or not we accept applications from this country",
      )
    end

    it do
      expect(subject).to validate_inclusion_of(:eligibility_route).in_array(
        %w[expanded reduced standard],
      )
    end

    it do
      expect(subject).to validate_presence_of(:has_regions).with_message(
        "You must select whether or not there are regions within in this " \
          "country that have a different teaching authority or service journey",
      )
    end

    it { is_expected.to validate_presence_of(:region_names) }

    context "when has_regions is false" do
      before { form.has_regions = false }

      it { is_expected.not_to validate_presence_of(:region_names) }
    end
  end
end
