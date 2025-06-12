# frozen_string_literal: true

require "rails_helper"

RSpec.describe EligibilityInterface::WorkExperienceInEnglandForm,
               type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:eligibility_check) }
  end

  describe "#valid?" do
    subject(:valid) { form.valid? }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) { described_class.new(eligibility_check:, eligible:) }
    let(:eligible) { "true" }

    it { is_expected.to be_truthy }

    context "when eligible is blank" do
      let(:eligible) { "" }

      it { is_expected.to be_falsy }
    end
  end

  describe "#save" do
    subject(:save!) { form.save }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) { described_class.new(eligibility_check:, eligible: true) }

    it "saves the eligibility check" do
      save!
      expect(eligibility_check.eligible_work_experience_in_england).to be_truthy
    end
  end
end
