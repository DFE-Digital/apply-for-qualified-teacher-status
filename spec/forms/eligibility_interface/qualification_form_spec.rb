# frozen_string_literal: true

require "rails_helper"

RSpec.describe EligibilityInterface::QualificationForm, type: :model do
  describe "#valid?" do
    subject(:valid) { form.valid? }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) { described_class.new(eligibility_check:, qualification:) }
    let(:qualification) { "true" }

    it { is_expected.to be_truthy }
    it { expect(form).to validate_presence_of(:eligibility_check) }

    context "when qualification is blank" do
      let(:qualification) { "" }

      it { is_expected.to be_falsy }
    end
  end

  describe "#save" do
    subject(:save!) { form.save }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) { described_class.new(eligibility_check:, qualification: true) }

    it "saves the eligibility check" do
      save!
      expect(eligibility_check.qualification).to be_truthy
    end
  end
end
