require "rails_helper"

RSpec.describe LocationForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:eligibility_check) }
    it { is_expected.to validate_presence_of(:country_code) }
  end

  describe "#valid?" do
    subject(:valid) { form.valid? }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) { described_class.new(eligibility_check:, country_code: "GB") }

    it { is_expected.to be_truthy }
  end

  describe "#save" do
    subject(:save!) { form.save }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) { described_class.new(eligibility_check:, country_code: "GB") }

    it "saves the eligibility check" do
      save!
      expect(eligibility_check.country_code).to eq("GB")
    end
  end
end
