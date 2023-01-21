# frozen_string_literal: true

require "rails_helper"

RSpec.describe Filters::Status do
  subject { described_class.apply(scope:, params:) }

  context "with states param and a single state" do
    let(:params) { { statuses: :draft } }
    let(:scope) { ApplicationForm.all }

    let!(:included) { create(:application_form, :draft) }

    let!(:filtered) { create(:application_form, :submitted) }

    it "returns a filtered scope" do
      expect(subject).to eq([included])
    end
  end

  context "wth states param and multiple states" do
    let(:params) { { statuses: %w[draft submitted] } }
    let(:scope) { ApplicationForm.all }

    let!(:included) do
      [create(:application_form, :draft), create(:application_form, :submitted)]
    end

    let!(:filtered) do
      create(:application_form, :awarded)
      create(:application_form, :declined)
    end

    it "returns a filtered scope" do
      expect(subject).to eq(included)
    end
  end

  context "with states param and a blank string" do
    let(:params) { { statuses: [""] } }
    let(:scope) { double }

    it "returns the original scope" do
      expect(subject).to eq(scope)
    end
  end

  context "without states param" do
    let(:params) { {} }
    let(:scope) { double }

    it "returns the original scope" do
      expect(subject).to eq(scope)
    end
  end
end
