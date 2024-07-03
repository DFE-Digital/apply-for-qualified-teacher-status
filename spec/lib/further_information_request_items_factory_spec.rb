# frozen_string_literal: true

require "rails_helper"

RSpec.describe FurtherInformationRequestItemsFactory do
  subject(:items) { described_class.call(assessment_sections:) }

  context "with no assessment sections" do
    let(:assessment_sections) { [] }

    it { is_expected.to be_empty }
  end

  context "with assessment section" do
    let(:assessment_sections) do
      [assessment_section_one, assessment_section_two]
    end
    let(:assessment_section_one) do
      create(
        :assessment_section,
        :personal_information,
        :failed,
        selected_failure_reasons: [failure_reason_one, failure_reason_two],
      )
    end

    let(:assessment_section_two) do
      create(
        :assessment_section,
        :qualifications,
        :failed,
        selected_failure_reasons: [failure_reason_three],
      )
    end

    let(:failure_reason_one) do
      build(:selected_failure_reason, key: "identification_document_expired")
    end
    let(:failure_reason_two) do
      build(
        :selected_failure_reason,
        key: "work_history_break",
        assessor_feedback: "More stuff needed",
      )
    end
    let(:failure_reason_three) do
      build(:selected_failure_reason, key: "duplicate_application")
    end

    it { is_expected.not_to be_empty }

    it "creates an item for each failure reason" do
      expect { subject }.to change(SelectedFailureReason, :count).by(3)
    end

    it "sets the information type" do
      expect(
        subject.find { |fi| fi.failure_reason_key == failure_reason_one.key },
      ).to be_document
    end

    it "sets the document type" do
      expect(
        subject
          .find { |fi| fi.failure_reason_key == failure_reason_one.key }
          .document,
      ).to be_identification
    end

    it "sets the text type" do
      expect(
        subject.find { |fi| fi.failure_reason_key == failure_reason_three.key },
      ).to be_text
    end

    it "sets the assessor feedback" do
      expect(
        subject
          .find { |fi| fi.failure_reason_key == failure_reason_two.key }
          .failure_reason_assessor_feedback,
      ).to eq(failure_reason_two.assessor_feedback)
    end
  end
end
