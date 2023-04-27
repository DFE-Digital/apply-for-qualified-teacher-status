# frozen_string_literal: true

class ResendStoredBlobDataJob < ApplicationJob
  # Resending the blob data will trigger a malware scan.
  def perform(batch_size: 1000)
    Upload
      .where(malware_scan_result: "pending")
      .limit(batch_size)
      .find_each do |upload|
        sleep(1) # Avoid rate limiting
        ResendStoredBlobData.call(upload:)
      end
  end
end
