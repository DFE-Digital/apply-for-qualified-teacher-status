# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher Interface - Further Information Request Items",
               type: :request do
  let(:teacher) { create(:teacher) }
  let(:application_form) do
    create(
      :application_form,
      :submitted,
      teacher:,
      statuses: %w[waiting_on_further_information],
    )
  end
  let(:assessment) { create(:assessment, application_form:) }
  let(:further_information_request) do
    create(:requested_further_information_request, assessment:)
  end
  let(:request_path) do
    teacher_interface_application_form_further_information_request_path(
      further_information_request,
    )
  end

  before { sign_in teacher, scope: :teacher }

  describe "PATCH /teacher/application/further_information_requests/:further_information_request_id/items/:id" do
    subject(:perform) do
      patch teacher_interface_application_form_further_information_request_further_information_request_item_path(
              further_information_request,
              item,
            ),
            params:
    end

    let(:params) { { button: "save_and_return" } }

    context "when saving a text response to come back later" do
      let(:item) do
        create(
          :further_information_request_item,
          :with_text_response,
          further_information_request:,
        )
      end
      let(:params) do
        {
          button: "save_and_return",
          teacher_interface_further_information_request_item_text_form: {
            response: "Example partial response",
          },
        }
      end

      it "saves the response and returns to the request without submitting it" do
        perform

        expect(response).to redirect_to(request_path)
        expect(item.reload.response).to eq("Example partial response")
        expect(further_information_request.reload).not_to be_received
      end
    end

    context "when saving incomplete referee details to come back later" do
      let(:item) do
        create(
          :further_information_request_item,
          :with_work_history_contact_response,
          further_information_request:,
        )
      end
      let(:params) do
        {
          button: "save_and_return",
          teacher_interface_further_information_request_item_work_history_contact_form: {
            contact_name: "Example Referee",
          },
        }
      end

      it "saves the details and returns to the request without submitting it" do
        perform

        expect(response).to redirect_to(request_path)
        expect(item.reload.contact_name).to eq("Example Referee")
        expect(further_information_request.reload).not_to be_received
      end
    end

    context "when saving a document prompt to come back later" do
      let(:item) do
        create(
          :further_information_request_item,
          :with_document_response,
          further_information_request:,
        )
      end

      it "returns to the request without submitting it" do
        perform

        expect(response).to redirect_to(request_path)
        expect(further_information_request.reload).not_to be_received
      end
    end
  end
end
