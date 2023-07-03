# frozen_string_literal: true

require "rails_helper"

RSpec.describe MigrateStoredBlobData do
  describe "#call" do
    subject(:call) { described_class.call(upload:) }

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

    around do |example|
      ClimateControl.modify AZURE_STORAGE_ACCOUNT_NAME_AKS: "name",
                            AZURE_STORAGE_ACCESS_KEY_AKS: "key" do
        example.run
      end
    end

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
      call
    end

    it "marks the file as migrated" do
      expect { call }.to change(upload, :migrated_to_aks).to(true)
    end

    context "when the upload attachment is missing" do
      let(:attachment) { instance_double(ActiveStorage::Blob) }
      before do
        allow(upload).to receive(:attachment).and_return(attachment)
        allow(attachment).to receive(:key).and_raise(
          ActiveStorage::FileNotFoundError,
        )
      end

      it "doesn't mark the file as migrated" do
        expect { call }.to_not change(upload, :migrated_to_aks)
      end
    end

    context "when the upload attachment key is nil" do
      let(:attachment) { instance_double(ActiveStorage::Blob, key: nil) }
      before { allow(upload).to receive(:attachment).and_return(attachment) }

      it "doesn't mark the file as migrated" do
        expect { call }.to_not change(upload, :migrated_to_aks)
      end
    end
  end
end
