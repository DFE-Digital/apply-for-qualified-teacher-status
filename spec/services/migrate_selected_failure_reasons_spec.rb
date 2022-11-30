# frozen_string_literal: true

require "rails_helper"

RSpec.describe MigrateSelectedFailureReasons do
  describe ".call" do
    let(:assessment_section) { create(:assessment_section, :qualifications) }
    subject { described_class.call(assessment_section:) }

    let(:reason_one_key) { assessment_section.failure_reasons.sample }
    let(:reason_one_assessor_feedback) { "Feeding back" }

    let(:reason_two_key) do
      (assessment_section.failure_reasons - [reason_one_key]).sample
    end
    let(:reason_two_assessor_feedback) { "" }

    let(:selected_failure_reasons) do
      {
        reason_one_key => reason_one_assessor_feedback,
        reason_two_key => reason_two_assessor_feedback,
      }
    end

    before do
      assessment_section.update(selected_failure_reasons:, passed: false)
    end

    context "when the assessment_section_failure_reasons don't exist yet" do
      it "creates one with feedback" do
        subject
        expect(
          assessment_section
            .assessment_section_failure_reasons
            .find_by(key: reason_one_key)
            .assessor_feedback,
        ).to eq(reason_one_assessor_feedback)
      end

      it "creates one with empty feedback" do
        subject
        expect(
          assessment_section
            .assessment_section_failure_reasons
            .find_by(key: reason_two_key)
            .assessor_feedback,
        ).to eq(reason_two_assessor_feedback)
      end
    end

    context "when the assessment_section_failure_reason already exists" do
      before do
        assessment_section.assessment_section_failure_reasons.create(
          key: reason_one_key,
          assessor_feedback: reason_one_assessor_feedback,
        )
      end

      it "creates any that are missing" do
        expect { subject }.to change {
          assessment_section.assessment_section_failure_reasons.count
        }.by(1)
      end

      it "doesn't create duplicates" do
        subject
        expect(
          assessment_section.assessment_section_failure_reasons.pluck(:key),
        ).to contain_exactly(reason_one_key, reason_two_key)
      end
    end

    context "when the assessment section doesn't have any failure reasons" do
      let(:selected_failure_reasons) { {} }

      it "doesn't create any" do
        expect { subject }.not_to(
          change do
            assessment_section.assessment_section_failure_reasons.count
          end,
        )
      end
    end
  end
end
