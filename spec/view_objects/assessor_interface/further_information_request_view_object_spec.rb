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
      application_form_id: application_form.id,
    }
  end

  describe "#check_your_answers_fields" do
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

    subject(:check_your_answers_fields) do
      view_object.check_your_answers_fields
    end

    it do
      is_expected.to eq(
        {
          text_item.id => {
            title: "Tell us more about the subjects you can teach",
            value: text_item.response,
          },
          document_item.id => {
            title: "Upload your identity document",
            value: document_item.document,
          },
        },
      )
    end
  end
end
