# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::CountryRegionForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:teacher) }
    it { is_expected.to validate_presence_of(:location) }

    context "with a location" do
      subject(:form) { described_class.new(location: "country:GB") }

      it { is_expected.to validate_presence_of(:region_id) }
    end
  end

  describe "#location=" do
    let(:form) { described_class.new(location: "country:#{country.code}") }

    context "with a single region" do
      let(:country) { create(:country, :with_national_region) }

      it "sets the region" do
        expect(form.region_id).to eq(country.regions.first.id)
      end
    end

    context "with multiple regions" do
      let(:country) do
        country = create(:country)
        create(:region, country:)
        create(:region, country:)
        country
      end

      it "doesn't set the region" do
        expect(form.region_id).to be_nil
      end
    end
  end

  describe "#regions" do
    subject(:regions) { form.regions }

    let(:form) { described_class.new(location: "country:#{country.code}") }
    let(:country) { create(:country) }
    let(:region_a) { create(:region, country:, name: "A") }
    let(:region_b) { create(:region, country:, name: "B") }

    it { is_expected.to eq([region_a, region_b]) }
  end

  describe "#needs_region?" do
    subject(:needs_region?) { form.needs_region? }

    let(:form) { described_class.new }

    it { is_expected.to be(false) }

    context "with a location set" do
      before { form.location = "country:GB" }

      it { is_expected.to be(true) }

      context "and a region set" do
        before { form.region_id = 1 }

        it { is_expected.to be(false) }
      end
    end
  end

  describe "#save" do
    let(:teacher) { create(:teacher) }
    let(:region) { create(:region, :national) }

    let(:form) do
      described_class.new(
        teacher:,
        location: "country:#{region.country.code}",
        region_id: region.id,
      )
    end

    before { form.save(validate: true) }

    it "creates an application form" do
      application_form = teacher.application_form
      expect(application_form).not_to be_nil
      expect(application_form.region).to eq(region)
    end
  end
end
