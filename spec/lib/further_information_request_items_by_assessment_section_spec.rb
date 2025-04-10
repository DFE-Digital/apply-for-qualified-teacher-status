# frozen_string_literal: true

require "rails_helper"

RSpec.describe FurtherInformationRequestItemsByAssessmentSection do
  describe "#call" do
    subject(:call) { described_class.call(further_information_request:) }

    let(:assessment) { create(:assessment) }

    let(:further_information_request) do
      create(:received_further_information_request, assessment:)
    end

    let!(:personal_information_assessment_section) do
      create :assessment_section, :personal_information, assessment:
    end

    let!(:qualifications_assessment_section) do
      create :assessment_section, :qualifications, assessment:
    end

    let!(:work_history_assessment_section) do
      create :assessment_section, :work_history, assessment:
    end

    let!(:professional_standing_assessment_section) do
      create :assessment_section, :professional_standing, assessment:
    end

    let!(:passport_document_illegible) do
      create(
        :further_information_request_item,
        :with_document_response,
        :completed,
        further_information_request:,
        failure_reason_key: "passport_document_illegible",
      )
    end

    let!(:passport_document_mismatch) do
      create(
        :further_information_request_item,
        :with_document_response,
        :completed,
        further_information_request:,
        failure_reason_key: "passport_document_mismatch",
      )
    end

    let!(:satisfactory_evidence_work_history) do
      create(
        :further_information_request_item,
        :with_text_response,
        :completed,
        further_information_request:,
        failure_reason_key: "satisfactory_evidence_work_history",
      )
    end

    let!(:qualifications_dont_match_other_details) do
      create(
        :further_information_request_item,
        :with_text_response,
        :completed,
        further_information_request:,
        failure_reason_key: "qualifications_dont_match_other_details",
      )
    end

    let!(:qualifications_or_modules_required_not_provided) do
      create(
        :further_information_request_item,
        :with_document_response,
        :completed,
        further_information_request:,
        failure_reason_key: "qualifications_or_modules_required_not_provided",
      )
    end

    let!(:written_statement_illegible) do
      create(
        :further_information_request_item,
        :with_document_response,
        :completed,
        further_information_request:,
        failure_reason_key: "written_statement_illegible",
      )
    end

    let!(:written_statement_recent) do
      create(
        :further_information_request_item,
        :with_document_response,
        :completed,
        further_information_request:,
        failure_reason_key: "written_statement_recent",
      )
    end

    before do
      create :selected_failure_reason,
             assessment_section: personal_information_assessment_section,
             key: "passport_document_illegible"
      create :selected_failure_reason,
             assessment_section: personal_information_assessment_section,
             key: "passport_document_mismatch"

      create :selected_failure_reason,
             assessment_section: qualifications_assessment_section,
             key: "qualifications_dont_match_other_details"
      create :selected_failure_reason,
             assessment_section: qualifications_assessment_section,
             key: "qualifications_or_modules_required_not_provided"

      create :selected_failure_reason,
             assessment_section: work_history_assessment_section,
             key: "satisfactory_evidence_work_history"

      create :selected_failure_reason,
             assessment_section: professional_standing_assessment_section,
             key: "written_statement_illegible"
      create :selected_failure_reason,
             assessment_section: professional_standing_assessment_section,
             key: "written_statement_recent"
    end

    it do
      expect(call).to eq(
        [
          [
            personal_information_assessment_section,
            [passport_document_illegible, passport_document_mismatch],
          ],
          [
            qualifications_assessment_section,
            [
              qualifications_dont_match_other_details,
              qualifications_or_modules_required_not_provided,
            ],
          ],
          [
            work_history_assessment_section,
            [satisfactory_evidence_work_history],
          ],
          [
            professional_standing_assessment_section,
            [written_statement_illegible, written_statement_recent],
          ],
        ],
      )
    end
  end
end
