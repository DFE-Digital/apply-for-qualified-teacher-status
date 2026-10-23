# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher Interface - Consent Requests", type: :request do
  let(:teacher) { create(:teacher) }
  let(:application_form) { create(:application_form, teacher:) }
  let(:assessment) { create(:assessment, application_form:) }

  before do
    sign_in teacher, scope: :teacher
    application_form.update!(assessment:)
  end

  describe "POST /teacher/application/consent-requests/:id/download" do
    subject(:perform) do
      post download_teacher_interface_application_form_consent_request_path(
             consent_request,
           ),
           params:
    end

    let(:consent_request) do
      create(:requested_consent_request, assessment:)
    end
    let(:params) { { button: "save_and_return" } }

    it "returns to the consent task list without confirming or submitting" do
      perform

      expect(response).to redirect_to(
        teacher_interface_application_form_consent_requests_path,
      )
      expect(consent_request.reload).not_to be_unsigned_document_downloaded
      expect(consent_request).not_to be_received
    end

    context "when the download is confirmed" do
      let(:params) do
        {
          button: "save_and_return",
          teacher_interface_download_unsigned_consent_document_form: {
            downloaded: "1",
          },
        }
      end

      it "saves the confirmation without submitting the consent request" do
        perform

        expect(response).to redirect_to(
          teacher_interface_application_form_consent_requests_path,
        )
        expect(consent_request.reload).to be_unsigned_document_downloaded
        expect(consent_request).not_to be_received
      end
    end

    context "when continuing without confirming the download" do
      let(:params) { { button: "save_and_continue" } }

      it "renders the validation error" do
        perform

        expect(response).to have_http_status(:unprocessable_entity)
        expect(consent_request.reload).not_to be_unsigned_document_downloaded
        expect(consent_request).not_to be_received
      end
    end
  end

  describe "POST /teacher/application/consent-requests/submit" do
    subject(:create_request) do
      post submit_teacher_interface_application_form_consent_requests_path(
             application_form,
           )
    end

    context "when all consent requests are already received" do
      before do
        create(:received_consent_request, assessment:)
        create(:received_consent_request, assessment:)
      end

      it "redirects safely to the application form" do
        create_request
        expect(response).to redirect_to(%i[teacher_interface application_form])
      end

      it "does not deliver a submission email" do
        expect(DeliverEmail).not_to receive(:call)
        create_request
      end

      it "does not attempt to receive the requestables again" do
        expect(ReceiveRequestable).not_to receive(:call)
        create_request
      end
    end

    context "when both consent requests are not received" do
      before do
        create(:requested_consent_request, assessment:)
        create(:requested_consent_request, assessment:)
      end

      it "redirects safely to the application form" do
        create_request
        expect(response).to redirect_to(%i[teacher_interface application_form])
      end

      it "delivers a submission email" do
        expect(DeliverEmail).to receive(:call)
        create_request
      end

      it "calls ReceiveRequestable twice" do
        expect(ReceiveRequestable).to receive(:call).twice
        create_request
      end
    end
  end
end
