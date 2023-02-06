# frozen_string_literal: true

module TeacherInterface
  class UploadForm < BaseForm
    attr_accessor :document
    attribute :original_attachment
    attribute :translated_attachment
    attribute :written_in_english, :boolean

    validates :document, presence: true
    validates :original_attachment, file_upload: true
    validates :translated_attachment, file_upload: true
    validates :written_in_english,
              inclusion: [true, false],
              if: -> { document&.translatable? }
    validates :written_in_english,
              absence: true,
              unless: -> { document&.translatable? }
    validate :attachments_present

    def update_model
      if original_attachment.present?
        document.uploads.create!(
          attachment: original_attachment,
          translation: false,
        )
      end

      if translated_attachment.present?
        document.uploads.create!(
          attachment: translated_attachment,
          translation: true,
        )
      end
    end

    delegate :application_form, to: :document

    def attachments_present
      has_errors =
        original_attachment.blank? ||
          (written_in_english == false && translated_attachment.blank?)

      # We lose any uploaded documents if the form isn't valid - the user has to upload both again,
      # so we should show both errors even if there was only one.

      if has_errors
        errors.add(:original_attachment, :blank)
        if written_in_english == false
          errors.add(:translated_attachment, :blank)
        end
      end
    end
  end
end
