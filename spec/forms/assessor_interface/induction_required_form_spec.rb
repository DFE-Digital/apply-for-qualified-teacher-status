# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::InductionRequiredForm, type: :model do
  subject(:form) do
    described_class.for_assessment_section(assessment_section).new(
      assessment_section:,
      user:,
      **attributes,
    )
  end

  let(:assessment_section) do
    create(:assessment_section, :professional_standing)
  end
  let(:user) { create(:staff) }
  let(:attributes) { {} }

  describe "validations" do
    it { is_expected.to validate_presence_of(:assessment_section) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to allow_values(true, false).for(:passed) }

    it do
      expect(subject).to allow_values(nil, true, false).for(:induction_required)
    end

    context "when passed" do
      let(:attributes) { { passed: "true" } }

      it { is_expected.not_to allow_values(nil).for(:induction_required) }
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    let(:assessment) { assessment_section.assessment }

    describe "when invalid attributes" do
      it { is_expected.to be false }
    end

    describe "with valid attributes" do
      let(:attributes) { { passed: true, induction_required: true } }

      it { is_expected.to be true }

      it "sets the attributes" do
        expect { save }.to change(assessment, :induction_required).to(true)
      end
    end
  end
end
