# frozen_string_literal: true

require "rails_helper"

RSpec.describe EligibilityInterface::TeachChildrenForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:eligibility_check) }
  end

  describe "#valid?" do
    subject(:valid) { form.valid? }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) { described_class.new(eligibility_check:, teach_children:) }
    let(:teach_children) { "true" }

    it { is_expected.to be_truthy }

    context "when teach_children is blank" do
      let(:teach_children) { "" }

      it { is_expected.to be_falsy }
    end
  end

  describe "#save" do
    subject(:save!) { form.save }

    let(:eligibility_check) { EligibilityCheck.new }
    let(:form) { described_class.new(eligibility_check:, teach_children: true) }

    it "saves the eligibility check" do
      save!
      expect(eligibility_check.teach_children).to be_truthy
    end
  end
end
