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
      expect(subject).to contain_exactly(included)
    end
  end

  context "wth states param and multiple states" do
    let(:params) do
      { statuses: %w[draft submitted waiting_on_further_information] }
    end
    let(:scope) { ApplicationForm.all }

    before do
      create(:application_form, :awarded)
      create(:application_form, :declined)
      create(:application_form, :declined, waiting_on_further_information: true)
    end

    let!(:included) do
      [
        create(:application_form, :draft),
        create(:application_form, :submitted),
        create(:application_form, waiting_on_further_information: true),
      ]
    end

    it "returns a filtered scope" do
      expect(subject).to match_array(included)
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
