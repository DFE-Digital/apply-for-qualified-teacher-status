# frozen_string_literal: true

module TeacherInterface
  class DeleteUploadForm < BaseForm
    attribute :confirm, :boolean
    attr_accessor :upload

    validates :confirm, inclusion: { in: [true, false] }
    validates :upload, presence: true, if: :confirm

    def update_model
      upload.destroy! if confirm

      document.update!(completed: false) if document.uploads.empty?
    end

    delegate :application_form, :document, to: :upload
  end
end
