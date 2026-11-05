# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher Interface - Documents", type: :request do
  let(:teacher) { create(:teacher) }
  let(:application_form) { create(:application_form, teacher:) }
  let(:document) { application_form.identification_document }

  before { sign_in teacher, scope: :teacher }

  describe "GET /teacher/application/documents/:id" do
    subject(:perform) do
      get teacher_interface_application_form_document_path(document)
    end

    before { perform }

    context "with no uploads" do
      it "redirects to upload" do
        expect(response).to redirect_to(
          new_teacher_interface_application_form_document_upload_path(document),
        )
      end
    end

    context "with an original upload" do
      let(:document) do
        create(:document, :with_upload, documentable: application_form)
      end

      it "redirects to review the uploaded files" do
        expect(response).to redirect_to(
          edit_teacher_interface_application_form_document_path(document),
        )
      end
    end

    context "with an original and a translation" do
      let(:document) do
        create(
          :document,
          :written_statement,
          :with_upload,
          :with_translation,
          documentable: application_form,
        )
      end

      it "redirects to review the uploaded files" do
        expect(response).to redirect_to(
          edit_teacher_interface_application_form_document_path(document),
        )
      end
    end

    context "with only a translation" do
      let(:document) do
        create(
          :document,
          :written_statement,
          :with_translation,
          documentable: application_form,
        )
      end

      it "redirects to upload" do
        expect(response).to redirect_to(
          new_teacher_interface_application_form_document_upload_path(document),
        )
      end

      it "retains the translation" do
        expect(document.reload.translated_uploads.count).to eq(1)
      end
    end

    context "with an optional written statement" do
      let(:document) do
        create(
          :document,
          :optional_written_statement,
          documentable: application_form,
        )
      end

      it "redirects to the availability form when there are no uploads" do
        expect(response).to redirect_to(
          edit_teacher_interface_application_form_document_path(document),
        )
      end

      context "with an original upload" do
        let(:document) do
          create(
            :document,
            :optional_written_statement,
            :with_upload,
            documentable: application_form,
          )
        end

        it "redirects to review the uploaded files" do
          expect(response).to redirect_to(
            edit_teacher_interface_application_form_document_path(document),
          )
        end
      end

      context "with only a translation" do
        let(:document) do
          create(
            :document,
            :optional_written_statement,
            :with_translation,
            documentable: application_form,
          )
        end

        it "redirects to upload" do
          expect(response).to redirect_to(
            new_teacher_interface_application_form_document_upload_path(
              document,
            ),
          )
        end
      end
    end
  end

  describe "PATCH /teacher/application/documents/:id" do
    subject(:perform) do
      patch teacher_interface_application_form_document_path(document),
            params: {
              button: "save_and_return",
            }
    end

    let!(:upload) { create(:upload, :clean, document:) }

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

    context "with a consent document" do
      let(:application_form) do
        create(
          :application_form,
          :submitted,
          teacher:,
          statuses: %w[waiting_on_consent],
        )
      end
      let(:assessment) { create(:assessment, application_form:) }
      let(:consent_request) { create(:requested_consent_request, assessment:) }
      let(:document) { consent_request.signed_consent_document }

      it "returns to the consent task list without submitting or removing uploads" do
        perform

        expect(response).to redirect_to(
          teacher_interface_application_form_consent_requests_path,
        )
        expect(document.uploads).to contain_exactly(upload)
        expect(consent_request.reload).not_to be_received
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
