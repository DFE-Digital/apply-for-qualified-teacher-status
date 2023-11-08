# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::FurtherInformationRequestViewObject do
  subject(:view_object) do
    described_class.new(params: ActionController::Parameters.new(params))
  end

  let(:application_form) { create(:application_form, :submitted) }
  let(:assessment) { create(:assessment, application_form:) }
  let(:further_information_request) do
    create(:further_information_request, :received, assessment:)
  end
  let(:params) do
    {
      id: further_information_request.id,
      assessment_id: assessment.id,
      application_form_reference: application_form.reference,
    }
  end

  describe "#review_items" do
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

    subject(:review_items) { view_object.review_items }

    it do
      is_expected.to eq(
        [
          {
            heading:
              "Subjects entered are acceptable for QTS, but the uploaded qualifications do not match them.",
            description: text_item.failure_reason_assessor_feedback,
            check_your_answers: {
              id: "further-information-requested-#{text_item.id}",
              model: text_item,
              title: "Further information requested",
              fields: {
                text_item.id => {
                  title: "Tell us more about the subjects you can teach",
                  value: text_item.response,
                },
              },
            },
          },
          {
            heading:
              "The ID document is illegible or in a format that we cannot accept.",
            description: document_item.failure_reason_assessor_feedback,
            check_your_answers: {
              id: "further-information-requested-#{document_item.id}",
              model: document_item,
              title: "Further information requested",
              fields: {
                document_item.id => {
                  title: "Upload your identity document",
                  value: document_item.document,
                },
              },
            },
          },
        ],
      )
    end
  end

  describe "#can_update?" do
    subject(:can_update?) { view_object.can_update? }

    context "when not passed and not recommended" do
      before do
        further_information_request.update!(review_passed: true)
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
