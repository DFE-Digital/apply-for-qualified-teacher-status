# frozen_string_literal: true

module TeacherInterface
  class DeleteUploadForm < BaseForm
    attribute :confirm, :boolean
    attr_accessor :upload

    validates :confirm, inclusion: { in: [true, false] }
    validates :upload, presence: true, if: :confirm

    def update_model
      upload.destroy! if confirm
    end

    delegate :application_form, to: :upload
  end
end
