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

  let(:personal_information_assessment_section) do
    create :assessment_section,
           :personal_information,
           assessment: further_information_request.assessment
  end

  let(:qualifications_assessment_section) do
    create :assessment_section,
           :qualifications,
           assessment: further_information_request.assessment
  end

  describe "#grouped_task_list_items" do
    subject(:grouped_task_list_items) { view_object.grouped_task_list_items }

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

    before do
      create :selected_failure_reason,
             assessment_section: personal_information_assessment_section,
             key: text_item.failure_reason_key

      create :selected_failure_reason,
             assessment_section: qualifications_assessment_section,
             key: document_item.failure_reason_key
    end

    it do
      expect(subject).to include(
        {
          heading: "About you",
          items: [
            title: "Tell us more about the subjects you can teach",
            description:
              "The subjects you entered are acceptable for QTS, but the uploaded qualifications do not match them",
            href: [
              :edit,
              :teacher_interface,
              :application_form,
              further_information_request,
              text_item,
            ],
            status: "not_started",
          ],
        },
      )
    end

    it do
      expect(subject).to include(
        {
          heading: "Your qualifications",
          items: [
            title: "Upload your identity document",
            description:
              "Your ID document is illegible or in a format we cannot accept",
            href: [
              :edit,
              :teacher_interface,
              :application_form,
              further_information_request,
              document_item,
            ],
            status: "not_started",
          ],
        },
      )
    end

    context "when items are incomplete" do
      it "disables check your answers in task list group" do
        check_answers_items = grouped_task_list_items.last
        expect(check_answers_items[:heading]).to eq("Check your answers")
        expect(check_answers_items[:items].first[:status]).to eq("cannot_start")
        expect(check_answers_items[:items].first[:href]).to be_nil
      end
    end

    context "when items are complete" do
      before do
        text_item.update!(response: "Response")
        create(
          :upload,
          :clean,
          document: document_item.document,
          filename: "upload.pdf",
        )
      end

      it "enables check your answers in task list group" do
        check_answers_items = grouped_task_list_items.last

        expect(check_answers_items[:heading]).to eq("Check your answers")
        expect(check_answers_items[:items].first[:status]).to eq("not_started")
        expect(check_answers_items[:items].first[:href]).to be_present
      end
    end
  end

  describe "#can_check_answers?" do
    subject(:can_check_answers?) { view_object.can_check_answers? }

    context "with incomplete items" do
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
    subject(:check_your_answers_fields) do
      view_object.check_your_answers_fields
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

    it do
      expect(subject).to eq(
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

    context "when the document item is passport" do
      let!(:document_item) do
        create(
          :further_information_request_item,
          :with_passport_document_response,
          :completed,
          further_information_request:,
        )
      end

      it do
        expect(subject).to eq(
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
              title: "Upload your passport",
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
end
