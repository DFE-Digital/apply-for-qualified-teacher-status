class FileUploadValidator < ActiveModel::EachValidator
  MAX_FILE_SIZE = 50.megabytes

  CONTENT_TYPES = {
    ".png" => "image/png",
    ".jpg" => "image/jpeg",
    ".pdf" => "application/pdf",
    ".doc" => "application/msword",
    ".docx" =>
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  }.freeze

  def validate_each(record, attribute, value)
    return if value.nil?

    if value.size >= MAX_FILE_SIZE
      record.errors.add attribute, :file_size_too_big
    end

    content_type = value.content_type
    extension = File.extname(value.original_filename)

    if !CONTENT_TYPES.values.include?(content_type) ||
         !CONTENT_TYPES.keys.include?(extension)
      record.errors.add attribute, :invalid_content_type
    elsif CONTENT_TYPES[extension] != content_type
      record.errors.add attribute, :mismatch_content_type
    end
  end
end
