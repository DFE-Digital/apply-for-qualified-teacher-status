# frozen_string_literal: true

module UploadableForm
  extend ActiveSupport::Concern

  included do
    attribute :original_attachment
    validates :original_attachment, file_upload: true

    attribute :translated_attachment
    validates :translated_attachment, file_upload: true

    attribute :written_in_english, :boolean
    validates :written_in_english,
              inclusion: [true, false],
              if: -> { document&.translatable? }
    validates :written_in_english,
              absence: true,
              unless: -> { document&.translatable? }

    validate :attachments_present
  end

  def create_uploads!
    document.uploads.each(&:destroy!) unless document.allow_multiple_uploads?

    if original_attachment.present?
      document.uploads.create!(
        attachment: original_attachment,
        filename: original_attachment.original_filename,
        translation: false,
      )
    end

    if translated_attachment.present?
      document.uploads.create!(
        attachment: translated_attachment,
        filename: translated_attachment.original_filename,
        translation: true,
      )
    end

    if FeatureFlags::FeatureFlag.active?(:fetch_malware_scan_result)
      fetch_and_update_malware_scan_results
    end
  end

  private

  def attachments_present
    has_errors =
      original_attachment.blank? ||
        (written_in_english == false && translated_attachment.blank?)

    # We lose any uploaded documents if the form isn't valid - the user has to upload both again,
    # so we should show both errors even if there was only one.

    if has_errors
      errors.add(:original_attachment, :blank)
      errors.add(:translated_attachment, :blank) if written_in_english == false
    end
  end

  def fetch_and_update_malware_scan_results
    document.uploads.each do |upload|
      UpdateMalwareScanResultJob.set(wait: 5.seconds).perform_later(upload)
    end
  end
end
