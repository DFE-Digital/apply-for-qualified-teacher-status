class TeacherInterface::DeleteUploadForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :upload

  attribute :confirm, :boolean

  validates :confirm, inclusion: { in: [true, false] }
  validates :upload, presence: true, if: :confirm

  def save!
    return unless valid?

    if confirm
      upload.attachment.purge
      upload.destroy!
    end
    true
  end
end
