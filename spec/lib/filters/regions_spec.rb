# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::Regions do
  subject { described_class.apply(scope:, params:) }

  let(:country) { create :country, code: "US" }

  let(:alabama) { create :region, name: "Alabama", country: }
  let(:hawaii) { create :region, name: "Hawaii", country: }
  let(:texas) { create :region, name: "Texas", country: }

  let!(:alabama_application) { create :application_form, region: alabama }

  let!(:hawaii_application_one) { create :application_form, region: hawaii }
  let!(:hawaii_application_two) { create :application_form, region: hawaii }

  let!(:texas_application_one) { create :application_form, region: texas }
  let!(:texas_application_two) { create :application_form, region: texas }
  let!(:texas_application_three) { create :application_form, region: texas }

  let(:scope) { ApplicationForm.all }

  before do
    create(
      :application_form,
      region: create(:region, :in_country, country_code: "FR"),
    )
    create(
      :application_form,
      region: create(:region, :in_country, country_code: "GH"),
    )
  end

  context "with location param" do
    let(:params) { { location: "country:US" } }

    it "returns a filtered scope" do
      expect(subject).to eq(scope)
    end

    context "when region_ids includes 1 US state" do
      let(:params) { { location: "country:US", region_ids: [texas.id] } }
      let(:filtered_results) do
        [texas_application_one, texas_application_two, texas_application_three]
      end

      it "returns a filtered scope" do
        expect(subject).to match_array(filtered_results)
      end
    end

    context "when region_ids includes multiple US state" do
      let(:params) do
        {
          location: "country:US",
          region_ids: [alabama.id, hawaii.id, texas.id],
        }
      end
      let(:filtered_results) do
        [
          alabama_application,
          hawaii_application_one,
          hawaii_application_two,
          texas_application_one,
          texas_application_two,
          texas_application_three,
        ]
      end

      it "returns a filtered scope" do
        expect(subject).to match_array(filtered_results)
      end
    end

    context "when the region_ids below to a different country" do
      let(:params) do
        {
          location: "country:GH",
          region_ids: [alabama.id, hawaii.id, texas.id],
        }
      end

      it "returns a filtered scope" do
        expect(subject).to eq(scope)
      end
    end

    context "when not country location provided with the region_ids" do
      let(:params) { { region_ids: [alabama.id, hawaii.id, texas.id] } }

      it "returns a filtered scope" do
        expect(subject).to eq(scope)
      end
    end
  end

  context "without location param" do
    let(:params) { {} }

    it "returns the original scope" do
      expect(subject).to eq(scope)
    end
  end
end
