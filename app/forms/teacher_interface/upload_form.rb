# frozen_string_literal: true

module TeacherInterface
  class UploadForm < BaseForm
    attr_accessor :document
    attribute :do_not_have_document, :boolean
    attribute :original_attachment
    attribute :translated_attachment
    attribute :written_in_english, :boolean

    validates :document, presence: true
    validates :original_attachment, file_upload: true
    validates :translated_attachment, file_upload: true
    validates :written_in_english,
              inclusion: [true, false],
              if: -> { document&.translatable? && !skippable? }
    validates :written_in_english,
              absence: true,
              unless: -> { document&.translatable? && !skippable? }
    validate :attachments_present

    attr_reader :timeout_error

    def update_model
      unless skippable?
        if original_attachment.present?
          upload =
            document.uploads.create!(
              attachment: original_attachment,
              translation: false,
            )
          FetchMalwareScanResultJob.set(wait: 1.minute).perform_later(upload)
        end

        if translated_attachment.present?
          upload =
            document.uploads.create!(
              attachment: translated_attachment,
              translation: true,
            )
          FetchMalwareScanResultJob.set(wait: 1.minute).perform_later(upload)
        end
      end

      document.update!(completed: skippable? || !document.uploads.empty?)
    end

    def save(validate:)
      super(validate:)
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError, Timeout::Error
      @timeout_error = true
      false
    end

    private

    delegate :application_form, to: :document

    def skippable?
      document&.optional? && do_not_have_document
    end

    def attachments_present
      return if skippable?

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
