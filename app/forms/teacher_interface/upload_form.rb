class TeacherInterface::UploadForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :document

  attribute :original_attachment
  attribute :translated_attachment

  validates :document, presence: true
  validates :original_attachment, file_upload: true
  validates :translated_attachment, file_upload: true

  def blank?
    original_attachment.blank? && translated_attachment.blank?
  end

  def save
    return false unless valid?
    return false if blank?

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

    true
  end
end
