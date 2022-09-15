class TeacherInterface::AddAnotherUploadForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :add_another, :boolean

  validates :add_another, inclusion: { in: [true, false] }
end
