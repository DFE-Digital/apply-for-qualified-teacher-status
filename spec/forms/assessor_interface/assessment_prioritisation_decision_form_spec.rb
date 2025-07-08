# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::AssessmentPrioritisationDecisionForm,
               type: :model do
  subject(:form) { described_class.new(assessment:, user:, passed:) }

  let(:assessment) { create :assessment }

  let(:user) { create :staff }

  let(:passed) { "" }

  describe "validations" do
    it { is_expected.to validate_presence_of(:assessment) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to allow_values(true, false).for(:passed) }
  end

  describe "#save" do
    subject(:save) { form.save }

    before { allow(PrioritiseAssessment).to receive(:call) }

    context "when passed" do
      let(:passed) { "true" }

      it { is_expected.to be true }

      it "calls the PrioritiseAssessment service" do
        subject

        expect(PrioritiseAssessment).to have_received(:call).with(
          assessment:,
          user:,
        )
      end
    end

    context "when not passed" do
      let(:passed) { "false" }

      it "raises 'Not Implemented' error" do
        expect { save }.to raise_error("Not Implemented")
      end
    end
  end
end
