# frozen_string_literal

require "rails_helper"

RSpec.describe UpdateAssessmentSection do
  let(:assessment_section) { create(:assessment_section, :personal_information) }
  let(:selected_failure_reason) { assessment_section.failure_reasons.sample }
  let(:params) { { passed: false, selected_failure_reasons: [selected_failure_reason] } }
  subject { described_class.call(assessment_section:, params:) }

  context "when the update is successful" do
    it "returns true" do
      expect(subject).to eq(true)
    end

    it "sets the state" do
      expect { subject }.to change { assessment_section.state }.from(:not_started).to(:action_required)
    end

    it "sets the failure reasons" do
      expect { subject }.to change { assessment_section.selected_failure_reasons }
        .from([]).to([selected_failure_reason])
    end
  end

  context "when the update fails" do
    before { allow(assessment_section).to receive(:update).and_return(false) }

    it "returns false" do
      expect(subject).to eq(false)
    end
  end
end
