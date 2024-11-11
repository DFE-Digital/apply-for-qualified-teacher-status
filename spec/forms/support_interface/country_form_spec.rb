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

  describe "#save" do
    subject(:save) { form.save! }

    let(:eligibility_enabled) { true }
    let(:eligibility_route) { "standard" }
    let(:has_regions) { true }
    let(:region_names) { "Madrid" }
    let(:country) { create(:country) }
    let(:other_information) { "Other information" }
    let(:status_information) { "Status information" }
    let(:sanction_information) { "Sanction information" }
    let(:teaching_qualification_information) do
      "Teaching qualification information"
    end
    let(:form) do
      described_class.new(
        country:,
        eligibility_enabled:,
        eligibility_route:,
        has_regions:,
        region_names:,
        other_information:,
        status_information:,
        sanction_information:,
        teaching_qualification_information:,
      )
    end

    context do
      it do
        subject
        expect { subject }.not_to(change(Country, :count))
      end
    end

    context "when there is one region specified" do
      it "creates a new region with the given attributes" do
        subject
        expect(Region.count).to eq(1)
        expect(Region.last).to have_attributes(name: "Madrid")
      end
    end

    context "when there are multiple regions specified" do
      let(:region_names) { "Madrid\nBarcelona" }

      it "creates multiple regions" do
        subject
        expect(Region.count).to eq(2)
        expect(Region.last).to have_attributes(name: "Madrid")
        expect(Region.first).to have_attributes(name: "Barcelona")
      end
    end

    context "when a region is removed" do
      let(:region_names) { "Madrid\nBarcelona" }

      before do
        Region.create!(name: "Madrid", country:)
        Region.create!(name: "Barcelona", country:)
        Region.create!(name: "Valencia", country:)
      end

      it "initially has three regions" do
        expect(Region.count).to eq(3)
      end

      it "removes one region" do
        save!
        expect(Region.count).to eq(2)
        expect(Region.last).to have_attributes(name: "Barcelona")
        expect(Region.first).to have_attributes(name: "Madrid")
      end
    end
  end
end
