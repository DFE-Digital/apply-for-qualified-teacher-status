# frozen_string_literal

require "rails_helper"

RSpec.describe UpdateAssessmentSection do
  let(:user) { build(:staff, id: 1) }
  let(:application_form) { create(:application_form, :submitted) }
  let(:assessment_section) do
    create(
      :assessment_section,
      :personal_information,
      assessment: create(:assessment, application_form:)
    )
  end
  let(:selected_failure_reason) { assessment_section.failure_reasons.sample }
  let(:params) do
    { passed: false, selected_failure_reasons: [selected_failure_reason] }
  end
  subject { described_class.call(assessment_section:, user:, params:) }

  context "when the update is successful" do
    it "returns true" do
      expect(subject).to eq(true)
    end

    it "sets the state" do
      expect { subject }.to change { assessment_section.state }.from(
        :not_started
      ).to(:action_required)
    end

    it "creates a timeline event" do
      expect { subject }.to change {
        TimelineEvent.assessment_section_recorded.count
      }.by(1)
    end

    it "sets the failure reasons" do
      expect { subject }.to change {
        assessment_section.selected_failure_reasons
      }.from([]).to([selected_failure_reason])
    end

    it "changes the application form state" do
      expect { subject }.to change { application_form.state }.from(
        "submitted"
      ).to("initial_assessment")
    end
  end

  context "when the update fails" do
    before { allow(assessment_section).to receive(:update).and_return(false) }

    it "returns false" do
      expect(subject).to eq(false)
    end

    it "doesn't create a timeline event" do
      expect { subject }.to_not(change { TimelineEvent.count })
    end

    it "doesn't change the application form state" do
      expect { subject }.to_not(change { application_form.state })
    end
  end
end
