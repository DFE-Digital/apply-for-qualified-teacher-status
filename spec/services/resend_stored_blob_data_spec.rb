# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResendStoredBlobData do
  describe "#call" do
    let(:upload) { create(:upload) }
    let(:response_success) { true }
    let(:put_blob_url) { "http://example.com/uploads/#{upload.attachment.key}" }
    let(:stubbed_blob_service) do
      instance_double(
        Azure::Storage::Blob::BlobService,
        generate_uri: put_blob_url,
      )
    end
    let(:stubbed_response) do
      instance_double(
        Azure::Core::Http::HttpResponse,
        success?: response_success,
      )
    end
    subject(:resend_stored_blob_data) { described_class.call(upload:) }

    before do
      allow(Azure::Storage::Blob::BlobService).to receive(:new).and_return(
        stubbed_blob_service,
      )
      allow(stubbed_blob_service).to receive(:call).and_return(stubbed_response)
    end

    it "calls the Azure Storage REST API to PUT blob data from the upload attachment" do
      expect(stubbed_blob_service).to receive(:call).with(
        :put,
        put_blob_url,
        upload.attachment.download,
        anything,
      )
      resend_stored_blob_data
    end

    it "enqueues a FetchMalwareScanResultJob" do
      expect(FetchMalwareScanResultJob).to receive(:set).with(
        wait: 1.minute,
      ).and_return(FetchMalwareScanResultJob)
      expect(FetchMalwareScanResultJob).to receive(:perform_later).with(
        upload_id: upload.id,
      )
      resend_stored_blob_data
    end

    context "when the upload attachment is missing" do
      let(:attachment) { instance_double(ActiveStorage::Blob) }
      before do
        allow(upload).to receive(:attachment).and_return(attachment)
        allow(attachment).to receive(:key).and_raise(
          ActiveStorage::FileNotFoundError,
        )
      end

      it "updates to the malware scan result field to 'error'" do
        resend_stored_blob_data
        expect(upload.reload.malware_scan_result).to eq("error")
      end
    end
  end
end
