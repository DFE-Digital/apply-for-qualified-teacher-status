# frozen_string_literal: true

require "rails_helper"

RSpec.describe EligibilityInterface::MisconductForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:eligibility_check) }
  end

  describe "#valid?" do
    subject(:valid) { form.valid? }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) { described_class.new(eligibility_check:, misconduct:) }
    let(:misconduct) { "true" }

    it { is_expected.to be_truthy }

    context "when misconduct is blank" do
      let(:misconduct) { "" }

      it { is_expected.to be_falsy }
    end
  end

  describe "#save" do
    subject(:save!) { form.save }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) { described_class.new(eligibility_check:, misconduct: false) }

    it "saves the eligibility check" do
      save!
      expect(eligibility_check.free_of_sanctions).to be_truthy
    end
  end
end
