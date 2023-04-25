# frozen_string_literal: true

class ResendStoredBlobDataJob < ApplicationJob
  # Resending the blob data will trigger a malware scan.
  def perform(batch_size: 100)
    Upload
      .where(malware_scan_result: "pending")
      .limit(batch_size)
      .find_each { |upload| ResendStoredBlobData.call(upload:) }
  end
end
