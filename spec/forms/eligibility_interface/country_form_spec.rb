# frozen_string_literal: true

require "rails_helper"

RSpec.describe EligibilityInterface::CountryForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:eligibility_check) }
    it { is_expected.to validate_presence_of(:location) }
  end

  describe "#valid?" do
    subject(:valid) { form.valid? }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) do
      described_class.new(eligibility_check:, location: "country:GB")
    end

    it { is_expected.to be_truthy }
  end

  describe "#save" do
    subject(:save!) { form.save }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) do
      described_class.new(eligibility_check:, location: "country:GB")
    end

    it "saves the eligibility check" do
      save!
      expect(eligibility_check.country_code).to eq("GB")
    end
  end
end
