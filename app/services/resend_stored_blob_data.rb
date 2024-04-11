# frozen_string_literal: true

class ResendStoredBlobData
  include ServicePattern

  # Only later versions of the Azure Storage REST API support tags operations.
  Kernel.silence_warnings do
    Azure::Storage::Blob::Default::STG_VERSION = "2022-11-02"
  end

  BLOB_CONTAINER_NAME = ENV["AZURE_STORAGE_CONTAINER"] || "uploads"

  def initialize(upload:)
    @upload = upload
  end

  def call
    unless upload.malware_scan_pending? && upload.attachment&.key.present?
      return
    end

    response = blob_service.call(:put, put_blob_url, attachment_data, headers)

    if response.success?
      UpdateMalwareScanResultJob.set(wait: 2.seconds).perform_later(upload)
    end
  rescue ActiveStorage::FileNotFoundError
    upload.update!(malware_scan_result: "error")
  end

  private

  attr_reader :upload

  def blob_service
    @blob_service ||=
      Azure::Storage::Blob::BlobService.new(
        storage_account_name: ENV["AZURE_STORAGE_ACCOUNT_NAME"],
        storage_access_key: ENV["AZURE_STORAGE_ACCESS_KEY"],
      )
  end

  def headers
    {
      "x-ms-blob-type" => "BlockBlob",
      "x-ms-version" => "2022-11-02",
      "Content-Length" => attachment_data.size,
    }
  end

  def attachment_data
    @attachment_data ||= upload.attachment.download
  end

  def put_blob_url
    blob_service.generate_uri(
      File.join(BLOB_CONTAINER_NAME, upload.attachment.key),
    )
  end
end
