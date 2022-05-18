require "rails_helper"

RSpec.describe CountryForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:eligibility_check) }
  end

  describe "#valid?" do
    subject(:valid) { form.valid? }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) { described_class.new(eligibility_check:, recognised:) }
    let(:recognised) { "true" }

    it { is_expected.to be_truthy }

    context "when recognised is blank" do
      let(:recognised) { "" }

      it { is_expected.to be_falsy }
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) { described_class.new(eligibility_check:, recognised: true) }

    it "saves the eligibility check" do
      save!
      expect(eligibility_check.recognised).to be_truthy
    end
  end
end
