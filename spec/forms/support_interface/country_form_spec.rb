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

    context "when form is valid" do
      it do
        subject
        expect(country.reload).to have_attributes(eligibility_enabled:)
        expect(subject).to be_truthy
      end

      it "increases the number of regions by 1" do
        expect { save }.to change(Region, :count).by(1)
      end
      #       it "creates a new region with the given attributes" do
      #         save
      #         region = Region.last
      #         expect(region.name).to eq("Madrid")
      #         expect(region.other_information).to eq("Other information")
      #         expect(region.status_information).to eq("Status information")
      #         expect(region.sanction_information).to eq("Sanction information")
      #         expect(region.teaching_qualification_information).to eq("Teaching qualification information")
      #       end
    end
    #     context "when form is invalid" do
    #       before do
    #       allow(subject).to receive(:valid?).and_return(false)
    #       end
    #       it 'raises an error' do
    #         expect { country_form.save! }.to raise_error(ActiveRecord::RecordInvalid)
    #       end
    #     end
  end
end
