# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::UploadsController, type: :controller do
  let(:teacher) { create(:teacher) }
  let(:application_form) { create(:application_form, teacher:) }

  before { sign_in teacher, scope: :teacher }

  describe "GET new" do
    subject(:perform) { get :new, params: { document_id: document.id } }

    let(:document) { create(:document, documentable: application_form) }

    include_examples "redirect unless application form is draft"
  end

  describe "POST create" do
    subject(:perform) { post :create, params: { document_id: document.id } }

    let(:document) { create(:document, documentable: application_form) }

    include_examples "redirect unless application form is draft"
  end

  describe "GET delete" do
    subject(:perform) do
      get :delete, params: { document_id: document.id, id: upload.id }
    end

    let(:document) { create(:document, documentable: application_form) }
    let(:upload) { create(:upload, document:) }

    include_examples "redirect unless application form is draft"
  end

  describe "DELETE destroy" do
    subject(:perform) do
      get :delete, params: { document_id: document.id, id: upload.id }
    end

    let(:document) { create(:document, documentable: application_form) }
    let(:upload) { create(:upload, document:) }

    include_examples "redirect unless application form is draft"
  end

  describe "GET show" do
    subject(:perform) do
      get :show, params: { document_id: document.id, id: upload.id }
    end

    let(:document) { create(:document, documentable: application_form) }
    let(:upload) { create(:upload, :clean, document:) }

    include_examples "redirect unless application form is draft"

    context "when the upload is present and user is authenticated" do
      it "renders the upload" do
        perform
        expect(response.status).to eq(200)
      end

      it "sends the blob stream" do
        perform
        expect(response.body).to eq(upload.attachment.blob.download)
      end
    end

    context "when the upload is not found" do
      before do
        allow(controller).to receive(:send_blob_stream).and_raise(
          ActiveStorage::FileNotFoundError,
        )
      end

      it "renders not found" do
        perform
        expect(response.status).to eq(404)
      end
    end

    context "when the upload times out" do
      before do
        allow(controller).to receive(:send_blob_stream).and_raise(
          Faraday::TimeoutError,
        )
      end

      it "renders internal server error" do
        perform
        expect(response.status).to eq(500)
      end
    end

    context "when the user session times out" do
      before { sign_out teacher }

      it "redirects to the signin page" do
        perform
        expect(response).to redirect_to(new_teacher_session_path)
      end
    end

    context "when the upload malware scan is not clean" do
      let(:upload) { create(:upload, :suspect, document:) }

      it "renders information about the scan result" do
        perform
        expect(response.status).to eq(403)
      end
    end
  end
end
