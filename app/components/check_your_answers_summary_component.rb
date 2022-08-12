class CheckYourAnswersSummaryComponent < ViewComponent::Base
  def initialize(model:, title:, fields:, delete_link_to: nil)
    super
    @model = model
    @title = title
    @fields = fields
    @delete_link_to = delete_link_to
  end

  attr_reader :title

  def rows
    fields_with_translations.map { |field| row_for_field(field) }
  end

  private

  attr_reader :model, :fields

  def fields_with_translations
    fields_as_array.flat_map do |field|
      has_translation?(field) ? [field, translation_row_for(field)] : field
    end
  end

  def has_translation?(field)
    object = model.send(field[:key])

    return false unless object.is_a?(Document)
    object.translated_uploads.any?
  end

  def row_title_for(field)
    field.fetch(:title, field[:key].to_s.humanize)
  end

  def translation_row_for(field)
    field.merge(translation: true, title: "#{row_title_for(field)} translation")
  end

  def fields_as_array
    fields.filter_map { |key, options| options&.merge(key:) }
  end

  def row_for_field(field)
    {
      key: field[:key],
      title: row_title_for(field),
      value: format_value(model.send(field[:key]), field),
      href: field.fetch(:href)
    }
  end

  def format_value(value, field)
    return "" if value.nil?

    if value.is_a?(Date)
      format = field[:format] == :without_day ? "%B %Y" : "%e %B %Y"
      return value.strftime(format).strip
    end

    return file_names_for(value, field[:translation]) if value.is_a?(Document)

    if value.is_a?(Array)
      return value.map { |v| format_value(v, field) }.join("<br />").html_safe
    end

    return "Yes" if value == true
    return "No" if value == false

    value.to_s
  end

  def file_names_for(document, translations)
    scope =
      translations ? document.translated_uploads : document.original_uploads
    scope
      .order(:created_at)
      .map { |upload| upload.attachment&.filename }
      .compact
      .join(", ")
  end
end
