require "spec_helper"

RSpec.describe EligibilityInterface::CompletedRequirementsForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:eligibility_check) }
  end

  describe "#valid?" do
    subject(:valid) { form.valid? }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) do
      described_class.new(eligibility_check:, completed_requirements:)
    end
    let(:completed_requirements) { "true" }

    it { is_expected.to be_truthy }

    context "when completed requirements is blank" do
      let(:completed_requirements) { "" }

      it { is_expected.to be_falsy }
    end
  end

  describe "#save" do
    subject(:save!) { form.save }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) do
      described_class.new(eligibility_check:, completed_requirements: true)
    end

    it "saves the eligibility check" do
      save!
      expect(eligibility_check.completed_requirements).to be_truthy
    end
  end
end
