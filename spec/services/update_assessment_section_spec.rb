# frozen_string_literal

require "rails_helper"

RSpec.describe UpdateAssessmentSection do
  let(:user) { build(:staff, id: 1) }
  let(:application_form) { create(:application_form, :submitted) }
  let(:assessment_section) do
    create(
      :assessment_section,
      :personal_information,
      assessment: create(:assessment, application_form:),
    )
  end
  let(:selected_failure_reasons) do
    { selected_failure_reason_key => selected_failure_reason_assessor_note }
  end
  let(:selected_failure_reason_key) do
    assessment_section.failure_reasons.sample
  end
  let(:selected_failure_reason_assessor_note) { "Epic fail" }
  let(:params) { { passed: false, selected_failure_reasons: } }

  subject { described_class.call(assessment_section:, user:, params:) }

  context "when the update is successful" do
    it { is_expected.to be true }

    it "sets the state" do
      expect { subject }.to change { assessment_section.state }.from(
        :not_started,
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
      }.from({}).to(selected_failure_reasons)
    end

    it "creates the assessment failure reason records" do
      expect { subject }.to change {
        AssessmentSectionFailureReason.where(
          assessment_section:,
          key: selected_failure_reason_key,
        ).count
      }.by(1)
    end

    it "changes the assessor" do
      expect { subject }.to change { application_form.assessor }.from(nil).to(
        user,
      )
    end

    context "with an existing assessor" do
      before { application_form.assessor = create(:staff) }

      it "doesn't change the assessor" do
        expect { subject }.to_not(change { application_form.assessor })
      end
    end

    it "changes the application form state" do
      expect { subject }.to change { application_form.state }.from(
        "submitted",
      ).to("initial_assessment")
    end
  end

  context "when the update fails" do
    before { allow(assessment_section).to receive(:update).and_return(false) }

    it { is_expected.to be false }

    it "doesn't create a timeline event" do
      expect { subject }.to_not(change { TimelineEvent.count })
    end

    it "doesn't change the assessor" do
      expect { subject }.to_not(change { application_form.assessor })
    end

    it "doesn't change the application form state" do
      expect { subject }.to_not(change { application_form.state })
    end
  end

  context "when the state is the same" do
    before { assessment_section.update!(params) }

    it "doesn't create a timeline event" do
      expect { subject }.to_not(
        change { TimelineEvent.assessment_section_recorded.count },
      )
    end
  end
end
