# frozen_string_literal: true

namespace :uploads do
  desc "Resend blob data for uploads that have a pending malware scan result"
  task update_filename: :environment do
    Upload
      .where(filename: "")
      .with_attached_attachment
      .find_each do |upload|
        upload.update!(filename: upload.attachment.filename || "unknown")
      end
  end
end
