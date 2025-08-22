# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::FurtherInformationRequestItemViewObject do
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
      id: further_information_request_item.id,
      application_form_id: application_form.id,
    }
  end

  describe "#item_name" do
    subject(:item_name) { view_object.item_name }

    context "when item is a text response" do
      let(:further_information_request_item) do
        create(
          :further_information_request_item,
          :with_text_response,
          further_information_request:,
        )
      end

      it { is_expected.to eq("Tell us more about the subjects you can teach") }
    end

    context "when item is a document response" do
      let(:further_information_request_item) do
        create(
          :further_information_request_item,
          :with_document_response,
          further_information_request:,
        )
      end

      it { is_expected.to eq("Upload your identity document") }
    end

    context "when item is a work history reference contact response" do
      let(:further_information_request_item) do
        create(
          :further_information_request_item,
          :with_work_history_contact_response,
          further_information_request:,
        )
      end

      it do
        expect(subject).to eq(
          "Update reference details for #{further_information_request_item.work_history.school_name}",
        )
      end
    end
  end

  describe "#item_description" do
    subject(:item_description) { view_object.item_description }

    let(:further_information_request_item) do
      create(
        :further_information_request_item,
        :with_text_response,
        further_information_request:,
      )
    end

    it do
      expect(subject).to eq(
        "The subjects you entered are acceptable for QTS, but the uploaded qualifications do not match them",
      )
    end
  end
end
