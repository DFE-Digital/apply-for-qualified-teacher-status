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

    let(:country) do
      create(
        :country,
        other_information:,
        status_information:,
        sanction_information:,
        teaching_qualification_information:,
      )
    end
    let(:other_information) { "Other information" }
    let(:status_information) { "Status information" }
    let(:sanction_information) { "Sanction information" }
    let(:teaching_qualification_information) do
      "Teaching qualification information"
    end

    it "returns a CountryForm for the country" do
      expect(subject).to have_attributes(
        eligibility_enabled: true,
        eligibility_route: "standard",
        has_regions: false,
        region_names: "",
        other_information: "Other information",
        status_information: "Status information",
        sanction_information: "Sanction information",
        teaching_qualification_information:
          "Teaching qualification information",
      )
    end

    context "when the country is subject limited" do
      let(:country) { create(:country, :subject_limited) }

      it "sets the eligibility route to expanded" do
        expect(subject).to have_attributes(eligibility_route: "expanded")
      end
    end

    context "when the country has eligibility skip questions" do
      let(:country) { create(:country, :eligibility_skip_questions) }

      it "sets the eligibility route to reduced" do
        expect(subject).to have_attributes(eligibility_route: "reduced")
      end
    end

    context "when the country has regions" do
      before do
        create(:region, name: "Madrid", country:)
        create(:region, name: "Barcelona", country:)
      end

      it "sets has_regions to true" do
        expect(subject).to have_attributes(
          has_regions: true,
          region_names: "Madrid\nBarcelona",
        )
      end
    end
  end
end
