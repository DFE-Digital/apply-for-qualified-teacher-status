# frozen_string_literal: true

require "rails_helper"

RSpec.describe SupportInterface::NewCountryForm, type: :model do
  describe "#valid?" do
    subject(:form) do
      described_class.new(
        location:,
        eligibility_route: "standard",
        has_regions: false,
        region_names: "",
      )
    end

    let(:location) { "country:AF" }

    it { is_expected.to be_valid }

    context "when location is blank" do
      let(:location) { "" }

      it { is_expected.not_to be_valid }
    end

    context "when location is not a recognised country code" do
      let(:location) { "country:INVALID" }

      it { is_expected.not_to be_valid }
    end

    context "when the country already exists" do
      let(:existing_country) { create(:country, code: "AF") }
      let(:location) { "country:AF" }

      before { existing_country }

      it { is_expected.not_to be_valid }
    end

    it do
      expect(subject).to validate_inclusion_of(:eligibility_route).in_array(
        %w[expanded reduced standard],
      )
    end

    it do
      expect(subject).to validate_inclusion_of(:has_regions).in_array(
        [true, false],
      )
    end

    context "when has_regions is true" do
      subject(:form) do
        described_class.new(
          location: "country:AF",
          eligibility_route: "standard",
          has_regions: true,
          region_names:,
        )
      end

      context "and region_names is blank" do
        let(:region_names) { "" }

        it { is_expected.not_to be_valid }
      end

      context "and region_names is present" do
        let(:region_names) { "Kabul" }

        it { is_expected.to be_valid }
      end
    end
  end

  describe "#save!" do
    subject(:save!) { form.save! }

    let(:form) do
      described_class.new(
        location:,
        eligibility_route:,
        has_regions:,
        region_names:,
      )
    end

    let(:location) { "country:AF" }
    let(:eligibility_route) { "standard" }
    let(:has_regions) { false }
    let(:region_names) { "" }

    it "creates a country with eligibility_enabled set to false" do
      country = subject
      expect(country).to have_attributes(
        code: "AF",
        eligibility_enabled: false,
        eligibility_skip_questions: false,
        subject_limited: false,
      )
    end

    it "creates a national region with a blank name" do
      country = subject
      expect(country.regions.count).to eq(1)
      expect(country.regions.first).to have_attributes(name: "")
    end

    context "when eligibility_route is reduced" do
      let(:eligibility_route) { "reduced" }

      it "sets eligibility_skip_questions to true" do
        country = subject
        expect(country).to have_attributes(
          eligibility_skip_questions: true,
          subject_limited: false,
        )
      end
    end

    context "when eligibility_route is expanded" do
      let(:eligibility_route) { "expanded" }

      it "sets subject_limited to true" do
        country = subject
        expect(country).to have_attributes(
          eligibility_skip_questions: false,
          subject_limited: true,
        )
      end
    end

    context "when has_regions is true" do
      let(:has_regions) { true }
      let(:region_names) { "Kabul\nHerat" }

      it "creates named regions" do
        country = subject
        expect(country.regions.count).to eq(2)
        expect(country.regions.map(&:name)).to contain_exactly("Kabul", "Herat")
      end
    end

    context "when form is invalid" do
      let(:location) { "" }

      it "raises ActiveRecord::RecordInvalid" do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "does not create a country" do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
        expect(Country.where(code: "AF")).not_to exist
      end
    end
  end
end
