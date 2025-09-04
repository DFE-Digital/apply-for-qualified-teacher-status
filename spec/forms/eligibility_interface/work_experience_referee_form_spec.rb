# frozen_string_literal: true

require "rails_helper"

RSpec.describe EligibilityInterface::WorkExperienceRefereeForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:eligibility_check) }
  end

  describe "#valid?" do
    subject(:valid) { form.valid? }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) do
      described_class.new(eligibility_check:, work_experience_referee:)
    end
    let(:work_experience_referee) { "true" }

    it { is_expected.to be_truthy }

    context "when work_experience_referee is blank" do
      let(:work_experience_referee) { "" }

      it { is_expected.to be_falsy }
    end
  end

  describe "#save" do
    subject(:save!) { form.save }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) do
      described_class.new(eligibility_check:, work_experience_referee: true)
    end

    it "saves the eligibility check" do
      save!
      expect(eligibility_check.work_experience_referee).to be_truthy
    end
  end
end
