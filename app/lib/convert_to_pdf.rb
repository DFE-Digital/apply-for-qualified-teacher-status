# frozen_string_literal: true

class ConvertToPDF
  include ServicePattern

  def initialize(document:, translation:)
    @document = document

    scope =
      (translation ? document.translated_uploads : document.original_uploads)

    @uploads =
      scope.order(:created_at).select { |upload| upload.attachment.present? }
  end

  def call
    return nil if uploads.count == 1 && uploads.all?(&:is_pdf?)

    combine_pdf =
      uploads.reduce(CombinePDF.new) do |accumulator, upload|
        open_file(upload:) { |file| accumulator << CombinePDF.load(file.path) }
      end

    combine_pdf.to_pdf
  end

  private

  attr_reader :document, :uploads

  def open_file(upload:, &block)
    blob = upload.attachment.blob

    if upload.is_pdf?
      blob.open(&block)
    elsif blob.image?
      open_image_as_pdf(blob:, &block)
    elsif is_document?(blob:)
      open_document_as_pdf(blob:, &block)
    end
  end

  def is_document?(blob:)
    %w[
      application/msword
      application/vnd.oasis.opendocument.text
      application/vnd.openxmlformats-officedocument.wordprocessingml.document
    ].include?(blob.content_type)
  end

  def open_document_as_pdf(blob:, &block)
    blob.open do |original_file|
      Tempfile.create(
        "converted-blob-#{blob.id}.pdf",
        binmode: true,
      ) do |converted_file|
        Libreconv.convert(original_file.path, converted_file.path)
        block.call(converted_file)
      end
    end
  end

  def open_image_as_pdf(blob:, &block)
    image = Magick::Image.from_blob(blob.download).first
    return if image.nil?

    image.format = "PDF"

    Tempfile.create("converted-image-#{blob.id}.pdf", binmode: true) do |file|
      image.write(file.path)
      block.call(file)
    end
  end
end
