# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::FurtherInformationRequestViewObject do
  subject(:view_object) do
    described_class.new(params: ActionController::Parameters.new(params))
  end

  let(:application_form) { create(:application_form, :submitted) }
  let(:assessment) { create(:assessment, application_form:) }
  let(:further_information_request) do
    create(:received_further_information_request, assessment:)
  end
  let(:params) do
    {
      id: further_information_request.id,
      assessment_id: assessment.id,
      application_form_reference: application_form.reference,
    }
  end

  describe "#grouped_review_items_by_assessment_section" do
    subject(:grouped_review_items_by_assessment_section) do
      view_object.grouped_review_items_by_assessment_section
    end

    let(:personal_information_assessment_section) do
      create :assessment_section, :personal_information, assessment:
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

    let(:qualifications_assessment_section) do
      create :assessment_section, :qualifications, assessment:
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
    end

    it do
      expect(subject).to eq(
        [
          {
            section_id: personal_information_assessment_section.id,
            heading: "Personal information",
            section_link_text: "Check original personal information details",
            review_items:
              view_object.review_items(
                [passport_document_mismatch, passport_document_illegible],
              ),
          },
          {
            section_id: qualifications_assessment_section.id,
            heading: "Qualifications",
            section_link_text: "Check original qualifications details",
            review_items:
              view_object.review_items(
                [
                  qualifications_or_modules_required_not_provided,
                  qualifications_dont_match_other_details,
                ],
              ),
          },
        ],
      )
    end
  end

  describe "#review_items" do
    subject(:review_items) do
      view_object.review_items(
        [text_item, document_item, work_history_contact_item],
      )
    end

    let!(:text_item) do
      create(
        :further_information_request_item,
        :with_text_response,
        :completed,
        further_information_request:,
      )
    end
    let!(:document_item) do
      create(
        :further_information_request_item,
        :with_document_response,
        :completed,
        further_information_request:,
      )
    end
    let!(:work_history_contact_item) do
      create(
        :further_information_request_item,
        :with_work_history_contact_response,
        :completed,
        further_information_request:,
        contact_email: "john@school.com",
        contact_job: "Principal",
        contact_name: "John Scott",
      )
    end

    it do
      expect(subject).to eq(
        [
          {
            id: document_item.id,
            recieved_date:
              further_information_request.received_at.to_date.to_fs,
            requested_date:
              further_information_request.requested_at.to_date.to_fs,
            heading:
              "The ID document is illegible or in a format that we cannot accept.",
            assessor_request: document_item.failure_reason_assessor_feedback,
            applicant_upload_response: document_item.document,
          },
          {
            id: text_item.id,
            recieved_date:
              further_information_request.received_at.to_date.to_fs,
            requested_date:
              further_information_request.requested_at.to_date.to_fs,
            heading:
              "Subjects entered are acceptable for QTS, but the uploaded qualifications do not match them.",
            assessor_request: text_item.failure_reason_assessor_feedback,
            applicant_text_response: text_item.response,
          },
          {
            id: work_history_contact_item.id,
            recieved_date:
              further_information_request.received_at.to_date.to_fs,
            requested_date:
              further_information_request.requested_at.to_date.to_fs,
            heading:
              "We could not verify 1 or more references entered by the applicant" \
                " for #{work_history_contact_item.work_history.school_name}.",
            assessor_request:
              work_history_contact_item.failure_reason_assessor_feedback,
            applicant_contact_response: [
              "Contact’s name: John Scott",
              "Contact’s job: Principal",
              "Contact’s email: john@school.com",
            ],
          },
        ],
      )
    end
  end

  describe "#can_update?" do
    subject(:can_update?) { view_object.can_update? }

    context "when not passed and not recommended" do
      before do
        further_information_request.update!(review_passed: false)
        assessment.request_further_information!
      end

      it { is_expected.to be true }
    end

    context "when passed and not recommended" do
      before do
        further_information_request.update!(review_passed: true)
        assessment.request_further_information!
      end

      it { is_expected.to be true }
    end

    context "when not passed and recommended" do
      before do
        further_information_request.update!(review_passed: nil)
        assessment.award!
      end

      it { is_expected.to be true }
    end

    context "when passed and recommended" do
      before do
        further_information_request.update!(review_passed: true)
        assessment.award!
      end

      it { is_expected.to be false }
    end
  end

  describe "#can_decline?" do
    subject(:can_update?) { view_object.can_decline? }

    let(:further_information_request) do
      create(:received_further_information_request, :with_items, assessment:)
    end

    context "when further information can be updated" do
      before do
        further_information_request.update!(review_passed: false)
        assessment.request_further_information!
      end

      context "with no decisions yet made on any of the further information request items" do
        it { is_expected.to be false }
      end

      context "with the further information request items being all accepted" do
        before do
          further_information_request.items.update_all(
            review_decision: "accept",
          )
        end

        it { is_expected.to be false }
      end

      context "with the further information request items being all declined" do
        before do
          further_information_request.items.update_all(
            review_decision: "decline",
          )
        end

        it { is_expected.to be true }
      end

      context "with the further information request items being mix of accept and decline" do
        before do
          further_information_request.items.first.update!(
            review_decision: "accept",
          )
          further_information_request.items.second.update!(
            review_decision: "accept",
          )
          further_information_request.items.third.update!(
            review_decision: "decline",
          )
        end

        it { is_expected.to be true }
      end
    end

    context "when further information cannot be updated" do
      before do
        further_information_request.update!(review_passed: true)
        assessment.award!
      end

      it { is_expected.to be false }
    end
  end
end
