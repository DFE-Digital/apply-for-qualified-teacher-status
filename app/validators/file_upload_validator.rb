# frozen_string_literal: true

class FileUploadValidator < ActiveModel::EachValidator
  MAX_FILE_SIZE = 50.megabytes

  CONTENT_TYPES = {
    ".png" => "image/png",
    ".jpg" => "image/jpeg",
    ".jpeg" => "image/jpeg",
    ".pdf" => "application/pdf",
    ".doc" => "application/msword",
    ".docx" =>
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  }.freeze

  def validate_each(record, attribute, uploaded_file)
    return if uploaded_file.nil?

    validate_file_size(record, attribute, uploaded_file)
    validate_content_type(record, attribute, uploaded_file)
    validate_pdf_not_encrypted(record, attribute, uploaded_file)
  end

  def validate_file_size(record, attribute, uploaded_file)
    if uploaded_file.size >= MAX_FILE_SIZE
      record.errors.add attribute, :file_size_too_big
    end
  end

  def validate_content_type(record, attribute, uploaded_file)
    content_type =
      Marcel::MimeType.for(
        uploaded_file,
        name: uploaded_file.original_filename,
        declared_type: uploaded_file.content_type,
      )

    extension = File.extname(uploaded_file.original_filename).downcase

    if !CONTENT_TYPES.values.include?(content_type) ||
         !CONTENT_TYPES.keys.include?(extension)
      record.errors.add attribute, :invalid_content_type
    elsif CONTENT_TYPES[extension] != content_type
      record.errors.add attribute, :mismatch_content_type
    end
  end

  def validate_pdf_not_encrypted(record, attribute, uploaded_file)
    output = `pdfinfo "#{uploaded_file.path}" 2> /dev/null`
    is_encrypted =
      output.lines.any? do |line|
        line.starts_with?("Encrypted") && line.include?("yes")
      end

    record.errors.add attribute, :encrypted_pdf if is_encrypted
  end
end
