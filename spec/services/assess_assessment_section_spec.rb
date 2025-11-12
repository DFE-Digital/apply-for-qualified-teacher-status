# frozen_string_literal: true

# frozen_string_literal

require "rails_helper"

RSpec.describe AssessAssessmentSection do
  subject(:call) do
    described_class.call(
      assessment_section,
      user:,
      passed:,
      selected_failure_reasons:,
    )
  end

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
  let(:selected_failure_reason_assessor_feedback) do
    { assessor_feedback: "Epic fail" }
  end
  let(:passed) { false }

  it "sets the status" do
    expect { call }.to change(assessment_section, :status).from(
      "not_started",
    ).to("rejected")
  end

  it "sets the assessed at date" do
    expect { travel_to(Date.new(2020, 1, 1)) { call } }.to change(
      assessment_section,
      :assessed_at,
    ).from(nil).to(Date.new(2020, 1, 1))
  end

  it "records a timeline event" do
    expect { call }.to have_recorded_timeline_event(
      :assessment_section_recorded,
    )
  end

  it "creates the assessment failure reason records" do
    expect { call }.to change {
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
        expect { call }.not_to(
          change do
            SelectedFailureReason.where(
              assessment_section:,
              key: selected_failure_reason_key,
            ).count
          end,
        )
      end

      it "updates the existing record" do
        expect { call }.to change {
          SelectedFailureReason.find_by(
            key: selected_failure_reason_key,
          ).assessor_feedback
        }.to(selected_failure_reason_assessor_feedback[:assessor_feedback])
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
        expect { call }.to change {
          SelectedFailureReason.where(key: different_key).count
        }.by(-1)
      end
    end
  end

  it "changes the assessor" do
    expect { call }.to change(application_form, :assessor).from(nil).to(user)
  end

  context "with an existing assessor" do
    before { application_form.assessor = create(:staff) }

    it "doesn't change the assessor" do
      expect { call }.not_to(change(application_form, :assessor))
    end
  end

  it "changes the application form state" do
    expect { call }.to change(application_form, :statuses).from(
      %w[assessment_not_started],
    ).to(%w[assessment_in_progress])
  end

  it "changes the assessment started at" do
    expect { call }.to change(assessment, :started_at).from(nil)
  end

  context "with an existing assessment started at" do
    before { assessment.update!(started_at: Date.new(2021, 1, 1)) }

    it "doesn't change the assessor" do
      expect { call }.not_to change(assessment, :started_at)
    end
  end

  context "with the failure reason requiring work history references" do
    let!(:work_histories) { create_list :work_history, 2, application_form: }

    let(:selected_failure_reason_key) do
      FailureReasons::WORK_HISTORY_REFERENCE_FAILURE_REASONS.sample
    end
    let(:selected_failure_reason_assessor_feedback) do
      {
        work_history_failure_reasons:
          work_histories.map do |work_history|
            {
              work_history_id: work_history.id,
              assessor_feedback: "Note: #{work_history.id}",
            }
          end,
      }
    end

    it "creates the assessment failure reason records with correct assessor note for each work history" do
      expect { call }.to change {
        SelectedFailureReason.where(
          assessment_section:,
          key: selected_failure_reason_key,
        ).count
      }.by(1)

      selected_failure_reason =
        SelectedFailureReason.find_by(
          assessment_section:,
          key: selected_failure_reason_key,
        )

      expect(selected_failure_reason.work_histories).to match_array(
        work_histories,
      )

      work_histories.each do |work_history|
        expect(
          selected_failure_reason
            .selected_failure_reasons_work_histories
            .find_by(work_history:)
            .assessor_feedback,
        ).to eq("Note: #{work_history.id}")
      end
    end
  end
end
