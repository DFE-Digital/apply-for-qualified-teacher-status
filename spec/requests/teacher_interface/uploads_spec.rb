# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher Interface - Uploads", type: :request do
  let(:teacher) { create(:teacher) }
  let(:application_form) { create(:application_form, teacher:) }
  let(:document) { application_form.identification_document }

  before { sign_in teacher, scope: :teacher }

  describe "POST /teacher/application/documents/:document_id/uploads" do
    subject(:perform) do
      post teacher_interface_application_form_document_uploads_path(document),
           params:
    end

    let(:params) { { button: "save_and_return" } }

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
      let(:request_path) do
        teacher_interface_application_form_further_information_request_path(
          further_information_request,
        )
      end

      it "returns from an unfinished upload to the request without submitting it" do
        perform

        expect(response).to redirect_to(request_path)
        expect(document.uploads).to be_empty
        expect(further_information_request.reload).not_to be_received
      end

      context "when a file is attached" do
        let(:params) do
          {
            button: "save_and_return",
            teacher_interface_upload_form: {
              original_attachment:
                Rack::Test::UploadedFile.new(
                  file_fixture("upload.pdf"),
                  "application/pdf",
                ),
            },
          }
        end

        it "saves the file and returns to the request without submitting it" do
          perform

          expect(response).to redirect_to(request_path)
          expect(document.uploads.pluck(:filename)).to eq(["upload.pdf"])
          expect(further_information_request.reload).not_to be_received
        end
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
