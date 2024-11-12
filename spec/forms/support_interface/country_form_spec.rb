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

    it "updates the country record attributes" do
      subject
      expect(country).to have_attributes(
        eligibility_enabled: true,
        other_information: "Other information",
        status_information: "Status information",
        sanction_information: "Sanction information",
        teaching_qualification_information:
          "Teaching qualification information",
        eligibility_skip_questions: false,
        subject_limited: false,
      )
    end

    it "creates a new region from the region name provided" do
      subject
      expect(country.regions.count).to eq(1)
      expect(country.regions.last).to have_attributes(name: "Madrid")
    end

    context "when the eligibility route is reduced" do
      let(:eligibility_route) { "reduced" }

      it "updates the country record attributes and sets eligibility_skip_questions to true" do
        subject
        expect(country).to have_attributes(
          eligibility_enabled: true,
          other_information: "Other information",
          status_information: "Status information",
          sanction_information: "Sanction information",
          teaching_qualification_information:
            "Teaching qualification information",
          eligibility_skip_questions: true,
          subject_limited: false,
        )
      end
    end

    context "when the eligibility route is expanded" do
      let(:eligibility_route) { "expanded" }

      it "updates the country record attributes and sets subject_limited to true" do
        subject
        expect(country).to have_attributes(
          eligibility_enabled: true,
          other_information: "Other information",
          status_information: "Status information",
          sanction_information: "Sanction information",
          teaching_qualification_information:
            "Teaching qualification information",
          eligibility_skip_questions: false,
          subject_limited: true,
        )
      end
    end

    context "when there are multiple regions specified" do
      let(:region_names) { "Madrid\nBarcelona" }

      it "creates multiple regions" do
        subject
        expect(country.regions.count).to eq(2)
        expect(country.regions.last).to have_attributes(name: "Madrid")
        expect(country.regions.first).to have_attributes(name: "Barcelona")
      end
    end

    context "when a region is removed" do
      let(:region_names) { "Madrid\nBarcelona" }

      before do
        create(:region, name: "Madrid", country:)
        create(:region, name: "Barcelona", country:)
        create(:region, name: "Valencia", country:)
      end

      it "removes one region" do
        expect(country.regions.count).to eq(3)
        subject
        expect(country.regions.reload.count).to eq(2)
        expect(country.regions.reload.map(&:name)).to contain_exactly(
          "Madrid",
          "Barcelona",
        )
      end
    end

    context "when there are no regions specified" do
      let(:has_regions) { false }

      it "updates the country record attributes" do
        subject
        expect(country).to have_attributes(
          eligibility_enabled: true,
          other_information: "",
          status_information: "",
          sanction_information: "",
          teaching_qualification_information: "",
          eligibility_skip_questions: false,
          subject_limited: false,
        )
      end

      it "only creates the national region" do
        subject
        expect(country.regions.reload.count).to eq(1)
        expect(country.regions.first).to have_attributes(name: "")
      end
    end

    context "when attributes are invalid" do
      let(:eligibility_route) { "invalid_route" }

      it "raises an error" do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe "#for_existing_country" do
    subject(:form) { described_class.for_existing_country(country) }

    let(:country) { create(:country) }

    it "returns a CountryForm" do
      expect(subject).to be_a(described_class)
      expect(form.eligibility_enabled).to eq(country.eligibility_enabled)
      expect(form.eligibility_route).to eq("standard")
      expect(form.has_regions).to eq(country.regions.count > 1)
      expect(form.region_names).to eq(country.regions.pluck(:name).join("\n"))
      expect(form.other_information).to eq(country.other_information)
      expect(form.status_information).to eq(country.status_information)
      expect(form.sanction_information).to eq(country.sanction_information)
      expect(form.teaching_qualification_information).to eq(
        country.teaching_qualification_information,
      )
    end

    context "when the country is subject limited" do
      let(:country) { create(:country, :subject_limited) }

      it "sets the eligibility route to expanded" do
        expect(form.eligibility_route).to eq("expanded")
      end
    end

    context "when the country has eligibility skip questions" do
      let(:country) { create(:country, :eligibility_skip_questions) }

      it "sets the eligibility route to reduced" do
        expect(form.eligibility_route).to eq("reduced")
      end
    end

    context "when the country has no regions" do
      let(:country) { create(:country, regions: []) }

      it "sets has_regions to false" do
        expect(form.has_regions).to be(false)
      end
    end
  end
end
