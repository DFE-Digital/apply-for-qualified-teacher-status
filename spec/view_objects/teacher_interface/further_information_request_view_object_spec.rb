# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::FurtherInformationRequestViewObject do
  subject(:view_object) do
    described_class.new(
      current_teacher:,
      params: ActionController::Parameters.new(params),
    )
  end

  let(:current_teacher) { create(:teacher, :confirmed) }
  let(:params) { {} }

  describe "#task_items" do
    let(:application_form) do
      create(:application_form, teacher: current_teacher)
    end
    let(:further_information_request) do
      create(
        :further_information_request,
        :requested,
        assessment: create(:assessment, application_form:),
      )
    end
    let(:params) do
      {
        id: further_information_request.id,
        application_form_id: application_form.id,
      }
    end

    let!(:text_item) do
      create(
        :further_information_request_item,
        :with_text_response,
        further_information_request:,
      )
    end
    let!(:document_item) do
      create(
        :further_information_request_item,
        :with_document_response,
        further_information_request:,
        document: create(:document, :identification_document),
      )
    end

    subject(:task_items) { view_object.task_items }

    it do
      is_expected.to eq(
        [
          {
            key: text_item.id,
            text: "Tell us more about the subjects you can teach",
            href: [
              :edit,
              :teacher_interface,
              :application_form,
              further_information_request,
              text_item,
            ],
            status: :not_started,
          },
          {
            key: document_item.id,
            text: "Upload your identity document",
            href: [
              :edit,
              :teacher_interface,
              :application_form,
              further_information_request,
              document_item,
            ],
            status: :not_started,
          },
        ],
      )
    end
  end
end
