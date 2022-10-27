# frozen_string_literal: true

module TeacherInterface
  class UploadForm < BaseForm
    attr_accessor :document
    attribute :original_attachment
    attribute :translated_attachment
    attribute :written_in_english, type: :boolean

    validates :document, presence: true
    validates :original_attachment, file_upload: true
    validates :translated_attachment, file_upload: true
    validate :attachment_present

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

    def attachment_present
      errors.add(:original_attachment, :blank) if original_attachment.blank?
      if written_in_english == "false" && translated_attachment.blank?
        errors.add(:translated_attachment, :blank)
      end
    end
  end
end
