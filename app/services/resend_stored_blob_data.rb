# frozen_string_literal: true

require "azure_blob"

class ResendStoredBlobData
  include ServicePattern

  BLOB_CONTAINER_NAME = ENV["AZURE_STORAGE_CONTAINER"] || "uploads"

  def initialize(upload:)
    @upload = upload
  end

  def call
    unless upload.malware_scan_pending? && upload.attachment&.key.present?
      return
    end

    success =
      blob_service.create_block_blob(
        File.join(BLOB_CONTAINER_NAME, upload.attachment.key),
        attachment_data,
      )

    if success
      UpdateMalwareScanResultJob.set(wait: 2.seconds).perform_later(upload)
    end
  rescue ActiveStorage::FileNotFoundError
    upload.update!(malware_scan_result: "error")
  end

  private

  attr_reader :upload

  def blob_service
    @blob_service ||=
      AzureBlob::Client.new(
        account_name: ENV["AZURE_STORAGE_ACCOUNT_NAME"],
        access_key: ENV["AZURE_STORAGE_ACCESS_KEY"],
        container: ENV["AZURE_STORAGE_CONTAINER"],
      )
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
