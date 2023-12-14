# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::FurtherInformationRequestViewObject do
  subject(:view_object) do
    described_class.new(
      current_teacher:,
      params: ActionController::Parameters.new(params),
    )
  end

  let(:current_teacher) { create(:teacher) }
  let(:application_form) { create(:application_form, teacher: current_teacher) }
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

  describe "#task_list_items" do
    subject(:task_list_items) { view_object.task_list_items }

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
      )
    end

    it do
      is_expected.to include(
        {
          title: "Tell us more about the subjects you can teach",
          href: [
            :edit,
            :teacher_interface,
            :application_form,
            further_information_request,
            text_item,
          ],
          status: "not_started",
        },
      )
    end

    it do
      is_expected.to include(
        {
          title: "Upload your identity document",
          href: [
            :edit,
            :teacher_interface,
            :application_form,
            further_information_request,
            document_item,
          ],
          status: "not_started",
        },
      )
    end
  end

  describe "#can_check_answers?" do
    subject(:can_check_answers?) { view_object.can_check_answers? }

    context "with uncomplete items" do
      before do
        create(:further_information_request_item, further_information_request:)
      end

      it { is_expected.to be false }
    end

    context "with complete items" do
      before do
        create(
          :further_information_request_item,
          :with_text_response,
          :completed,
          further_information_request:,
        )
      end

      it { is_expected.to be true }
    end
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
            href: [
              :edit,
              :teacher_interface,
              :application_form,
              further_information_request,
              text_item,
            ],
            value: text_item.response,
          },
          document_item.id => {
            title: "Upload your identity document",
            href: [
              :edit,
              :teacher_interface,
              :application_form,
              further_information_request,
              document_item,
            ],
            value: document_item.document,
          },
        },
      )
    end
  end
end
