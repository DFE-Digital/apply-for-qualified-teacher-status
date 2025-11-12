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
        selected_failure_reasons: [
          failure_reason_three,
          failure_reason_work_history,
        ],
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

    let!(:failure_reason_work_history) do
      create(
        :selected_failure_reason,
        key: "unrecognised_references",
        assessor_feedback: "Original assessor feedback",
        work_histories: create_list(:work_history, 2),
      )
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

    context "when failure reason has work histories" do
      it "generates a further information item for each work history" do
        further_information_requests =
          subject.select do |fi|
            fi.failure_reason_key == failure_reason_work_history.key
          end
        expect(further_information_requests.count).to eq(2)

        expect(
          further_information_requests.first.failure_reason_assessor_feedback,
        ).to eq("Original assessor feedback")

        expect(
          further_information_requests.last.failure_reason_assessor_feedback,
        ).to eq("Original assessor feedback")
      end

      context "when the selected failure reasons work histories have their own assessor feedback" do
        before do
          failure_reason_work_history.selected_failure_reasons_work_histories.update_all(
            assessor_feedback: "Work history feedback",
          )
        end

        it "sets the selected failure reason specific for the work history as the feedback" do
          further_information_requests =
            subject.select do |fi|
              fi.failure_reason_key == failure_reason_work_history.key
            end

          expect(
            further_information_requests.first.failure_reason_assessor_feedback,
          ).to eq("Work history feedback")

          expect(
            further_information_requests.last.failure_reason_assessor_feedback,
          ).to eq("Work history feedback")
        end
      end
    end
  end
end
