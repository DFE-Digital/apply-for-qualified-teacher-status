class FileUploadValidator < ActiveModel::EachValidator
  MAX_FILE_SIZE = 50.megabytes
  CONTENT_TYPES = %w[
    image/png
    image/jpeg
    application/pdf
    application/msword
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
  ].freeze

  def validate_each(record, attribute, value)
    return if value.nil?

    if value.size >= MAX_FILE_SIZE
      record.errors.add attribute, :file_size_too_big
    end

    unless CONTENT_TYPES.include?(value.content_type)
      record.errors.add attribute, :invalid_content_type
    end
  end
end
