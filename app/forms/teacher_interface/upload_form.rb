class TeacherInterface::UploadForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveStorageValidations

  attr_accessor :document

  attribute :original_attachment
  attribute :translated_attachment

  validates :document, presence: true

  validates :original_attachment,
            content_type: %i[png jpg jpeg pdf doc docx],
            size: {
              less_than: 50.megabytes
            },
            allow_nil: true

  validates :translated_attachment,
            content_type: %i[png jpg jpeg pdf doc docx],
            size: {
              less_than: 50.megabytes
            },
            allow_nil: true

  def present?
    original_attachment.present? || translated_attachment.present?
  end

  def save
    return false unless valid?
    return false if blank?

    if original_attachment.present?
      document.uploads.create!(
        attachment: original_attachment,
        translation: false
      )
    end

    if translated_attachment.present?
      document.uploads.create!(
        attachment: translated_attachment,
        translation: true
      )
    end

    true
  end
end

# The following is required as we're using a validation library which is
# usually used directly on a model and received an ActiveStorage::Blob
# rather than an ActionDispatch::Http::UploadedFile.
class ActionDispatch::Http::UploadedFile
  def attached?
    true
  end

  def blob
    self
  end

  def byte_size
    size
  end
end
