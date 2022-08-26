# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::Country do
  subject { described_class.apply(scope:, params:) }

  context "with location param" do
    let(:params) { { location: "country:US" } }
    let(:scope) { ApplicationForm.all }

    let!(:included) do
      create(
        :application_form,
        region: create(:region, country: create(:country, code: "US"))
      )
    end
    let!(:filtered) do
      create(
        :application_form,
        region: create(:region, country: create(:country, code: "FR"))
      )
    end

    it "returns a filtered scope" do
      expect(subject).to eq([included])
    end
  end

  context "without location param" do
    let(:params) { {} }
    let(:scope) { double }

    it "returns the original scope" do
      expect(subject).to eq(scope)
    end
  end
end
