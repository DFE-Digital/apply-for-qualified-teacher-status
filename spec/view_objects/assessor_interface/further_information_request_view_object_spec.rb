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

  describe "#review_items" do
    subject(:review_items) { view_object.review_items }

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
            id: "further-information-requested-#{text_item.id}",
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
            id: "further-information-requested-#{document_item.id}",
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
            id: "further-information-requested-#{work_history_contact_item.id}",
            recieved_date:
              further_information_request.received_at.to_date.to_fs,
            requested_date:
              further_information_request.requested_at.to_date.to_fs,
            heading:
              "We could not verify 1 or more references entered by the applicant.",
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
end
