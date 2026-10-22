# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher Interface - Documents", type: :request do
  let(:teacher) { create(:teacher) }
  let(:application_form) { create(:application_form, teacher:) }
  let(:document) { application_form.identification_document }
  let!(:upload) { create(:upload, :clean, document:) }

  before { sign_in teacher, scope: :teacher }

  describe "PATCH /teacher/application/documents/:id" do
    subject(:perform) do
      patch teacher_interface_application_form_document_path(document),
            params: {
              button: "save_and_return",
            }
    end

    context "with a further-information document" do
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
      let(:item) do
        create(
          :further_information_request_item,
          :with_document_response,
          further_information_request:,
        )
      end
      let(:document) { item.document }

      it "returns to the request without submitting it or removing uploads" do
        perform

        expect(response).to redirect_to(
          teacher_interface_application_form_further_information_request_path(
            further_information_request,
          ),
        )
        expect(document.uploads).to contain_exactly(upload)
        expect(further_information_request.reload).not_to be_received
      end
    end

    context "with a normal application document" do
      it "returns to the main application page" do
        perform

        expect(response).to redirect_to(teacher_interface_application_form_path)
      end
    end
  end
end
