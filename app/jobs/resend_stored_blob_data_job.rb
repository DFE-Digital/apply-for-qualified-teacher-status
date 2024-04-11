# frozen_string_literal: true

class ResendStoredBlobDataJob < ApplicationJob
  # Resending the blob data will trigger a malware scan.
  def perform(batch_size: 1000)
    return unless FeatureFlags::FeatureFlag.active?(:fetch_malware_scan_result)

    Upload
      .malware_scan_pending
      .limit(batch_size)
      .find_each do |upload|
        sleep(2) # Avoid rate limiting
        ResendStoredBlobData.call(upload:)
      end
  end
end
