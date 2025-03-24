# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResendStoredBlobData do
  describe "#call" do
    subject(:resend_stored_blob_data) { described_class.call(upload:) }

    let(:upload) { create(:upload) }
    let(:response_success) { true }
    let(:put_blob_url) { "http://example.com/uploads/#{upload.attachment.key}" }
    let(:stubbed_blob_service) do
      instance_double(AzureBlob::Client, generate_uri: put_blob_url)
    end

    before do
      allow(AzureBlob::Client).to receive(:new).and_return(stubbed_blob_service)
      allow(stubbed_blob_service).to receive(:create_block_blob).and_return(
        response_success,
      )
    end

    it "calls the Azure Storage REST API to PUT blob data from the upload attachment" do
      resend_stored_blob_data

      expect(stubbed_blob_service).to have_received(:create_block_blob).with(
        "uploads/#{upload.attachment.key}",
        upload.attachment.download,
      )
    end

    it "enqueues a FetchMalwareScanResultJob" do
      expect { resend_stored_blob_data }.to have_enqueued_job(
        UpdateMalwareScanResultJob,
      ).with(upload)
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

    context "when the upload attachment key is nil" do
      let(:attachment) { instance_double(ActiveStorage::Blob, key: nil) }

      before { allow(upload).to receive(:attachment).and_return(attachment) }

      it "returns without update" do
        expect { resend_stored_blob_data }.not_to change(
          upload.reload,
          :malware_scan_result,
        )
      end
    end
  end
end
