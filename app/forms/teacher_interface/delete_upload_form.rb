# frozen_string_literal: true

class TeacherInterface::DeleteUploadForm < TeacherInterface::BaseForm
  attr_accessor :upload
  attribute :confirm, :boolean

  validates :upload, presence: true
  validates :confirm, inclusion: { in: [true, false] }

  def update_model
    upload.destroy! if confirm
  end

  delegate :application_form, :document, to: :upload
end
