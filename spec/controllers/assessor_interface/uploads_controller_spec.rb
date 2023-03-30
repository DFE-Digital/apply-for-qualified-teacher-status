# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::UploadsController, type: :controller do
  before { FeatureFlags::FeatureFlag.activate(:service_open) }

  let(:staff) { create(:staff, :with_award_decline_permission, :confirmed) }
  let(:application_form) { create(:application_form) }

  before { sign_in staff, scope: :staff }

  describe "GET show" do
    let(:document) { create(:document, documentable: application_form) }
    let(:upload) { create(:upload, document:) }

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
  end
end
