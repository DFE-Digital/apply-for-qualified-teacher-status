# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::UploadsController, type: :controller do
  let(:staff) { create(:staff, :with_assess_permission) }
  let(:application_form) { create(:application_form) }

  before { sign_in staff, scope: :staff }

  describe "GET show" do
    let(:document) { create(:document, documentable: application_form) }
    let(:upload) { create(:upload, :clean, document:) }

    subject(:perform) do
      get :show, params: { document_id: document.id, id: upload.id }
    end

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
      before { sign_out staff }

      it "redirects to the signin page" do
        perform
        expect(response).to redirect_to(new_staff_session_path)
      end
    end

    context "when the upload malware scan is not clean" do
      render_views true
      let(:upload) { create(:upload, :suspect, document:) }

      before { FeatureFlags::FeatureFlag.activate(:fetch_malware_scan_result) }

      it "responds with information about the malware scan" do
        perform
        expect(response.body).to include("There’s a problem with your file")
      end
    end
  end
end
