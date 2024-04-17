# frozen_string_literal: true

class TeacherInterface::AddAnotherUploadForm < TeacherInterface::BaseForm
  attribute :add_another, :boolean
  validates :add_another, inclusion: { in: [true, false] }

  def update_model
  end
end
