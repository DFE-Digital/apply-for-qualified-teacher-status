# frozen_string_literal

require "rails_helper"

RSpec.describe UpdateAssessmentSection do
  let(:user) { create(:staff) }
  let(:application_form) { create(:application_form, :submitted) }
  let(:assessment) { create(:assessment, application_form:) }
  let(:assessment_section) do
    create(:assessment_section, :personal_information, assessment:)
  end
  let(:selected_failure_reasons) do
    { selected_failure_reason_key => selected_failure_reason_assessor_feedback }
  end
  let(:selected_failure_reason_key) { "identification_document_expired" }
  let(:selected_failure_reason_assessor_feedback) { { notes: "Epic fail" } }
  let(:params) { { passed: false, selected_failure_reasons: } }

  subject { described_class.call(assessment_section:, user:, params:) }

  context "when the update is successful" do
    it { is_expected.to be true }

    it "sets the state" do
      expect { subject }.to change(assessment_section, :status).from(
        :not_started,
      ).to(:completed)
    end

    it "records a timeline event" do
      expect { subject }.to have_recorded_timeline_event(
        :assessment_section_recorded,
      )
    end

    it "creates the assessment failure reason records" do
      expect { subject }.to change {
        SelectedFailureReason.where(
          assessment_section:,
          key: selected_failure_reason_key,
        ).count
      }.by(1)
    end

    context "when the failure reason already exists" do
      context "when the feedback has been updated" do
        before do
          assessment_section.selected_failure_reasons.create(
            key: selected_failure_reason_key,
            assessor_feedback: "I need updating",
          )
        end

        it "doesn't create a new assessment failure reason record" do
          expect { subject }.not_to(
            change do
              SelectedFailureReason.where(
                assessment_section:,
                key: selected_failure_reason_key,
              ).count
            end,
          )
        end

        it "updates the existing record" do
          expect { subject }.to change {
            SelectedFailureReason.find_by(
              key: selected_failure_reason_key,
            ).assessor_feedback
          }.to(selected_failure_reason_assessor_feedback[:notes])
        end
      end

      context "when the failure reason is no longer selected" do
        let(:different_key) do
          (
            assessment_section.failure_reasons -
              Array(selected_failure_reason_key)
          ).sample
        end

        before do
          assessment_section.selected_failure_reasons.create(
            key: different_key,
            assessor_feedback: "I need deleting",
          )
        end

        it "deletes the now unselected failure reason" do
          expect { subject }.to change {
            SelectedFailureReason.where(key: different_key).count
          }.by(-1)
        end
      end
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
      expect { subject }.to change { application_form.status }.from(
        "submitted",
      ).to("assessment_in_progress")
    end

    it "changes the assessment started at" do
      expect { subject }.to change(assessment, :started_at).from(nil)
    end

    context "with an existing assessment started at" do
      before { assessment.update!(started_at: Date.new(2021, 1, 1)) }

      it "doesn't change the started" do
        expect { subject }.to_not change(assessment, :started_at)
      end
    end

    context "with a preliminary assessment section" do
      before { assessment_section.update!(preliminary: true) }

      it "doesn't change the started" do
        expect { subject }.to_not change(assessment, :started_at)
      end
    end
  end

  context "when the update fails" do
    before { allow(assessment_section).to receive(:update).and_return(false) }

    it { is_expected.to be false }

    it "doesn't record a timeline event" do
      expect { subject }.to_not have_recorded_timeline_event(
        :assessment_section_recorded,
      )
    end

    it "doesn't change the assessor" do
      expect { subject }.to_not change(application_form, :assessor)
    end

    it "doesn't change the application form state" do
      expect { subject }.to_not change(application_form, :status)
    end

    it "doesn't change the assessment started at" do
      expect { subject }.to_not change(assessment, :started_at)
    end
  end

  context "when the state is the same" do
    let(:other_params) { { passed: false, selected_failure_reasons: } }
    before do
      described_class.call(assessment_section:, user:, params: other_params)
    end

    it "doesn't record a timeline event" do
      expect { subject }.to_not have_recorded_timeline_event(
        :assessment_section_recorded,
      )
    end
  end
end
