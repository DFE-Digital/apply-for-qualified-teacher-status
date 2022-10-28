module CheckYourAnswersSummary
  class Component < ViewComponent::Base
    def initialize(
      model:,
      id:,
      title:,
      fields:,
      changeable: true,
      delete_link_to: nil
    )
      super
      @model = model
      @id = "app-check-your-answers-summary-#{id}"
      @title = title
      @fields = fields
      @changeable = changeable
      @delete_link_to = delete_link_to
    end

    attr_reader :title

    def rows
      fields_with_translations.map { |field| row_for_field(field) }
    end

    def delete_link_to
      path_with_next(@delete_link_to) if changeable && @delete_link_to
    end

    private

    attr_reader :id, :model, :fields, :changeable

    def fields_with_translations
      fields_as_array.flat_map do |field|
        has_translation?(field) ? [field, translation_row_for(field)] : field
      end
    end

    def has_translation?(field)
      object = value_for(field)
      return false unless object.is_a?(Document)
      object.translated_uploads.any?
    end

    def row_title_for(field)
      field.fetch(:title, field[:key].to_s.humanize)
    end

    def translation_row_for(field)
      field.merge(
        translation: true,
        title: "#{row_title_for(field)} translation",
      )
    end

    def fields_as_array
      fields.filter_map { |key, options| options&.merge(key:) }
    end

    def value_for(field)
      field.include?(:value) ? field[:value] : model.send(field[:key])
    end

    def href_for(field)
      if (path = field[:href]).present?
        path_with_next(path)
      end
    end

    def path_with_next(path)
      next_path = request.path

      if path.is_a?(String)
        return "#{path}?#{URI.encode_www_form(next: next_path)}"
      end

      Rails.application.routes.url_helpers.polymorphic_path(
        path,
        next: next_path,
      )
    end

    def row_for_field(field)
      {
        key: field[:key],
        title: row_title_for(field),
        value: format_value(value_for(field), field),
        href: changeable ? href_for(field) : nil,
      }
    end

    def format_value(value, field)
      return "" if value.nil?

      if value.is_a?(Date)
        format = field[:format] == :without_day ? "%B %Y" : "%e %B %Y"
        return value.strftime(format).strip
      end

      return file_links_for(value, field[:translation]) if value.is_a?(Document)

      if value.is_a?(Array)
        return value.map { |v| format_value(v, field) }.join("<br />").html_safe
      end

      return "Yes" if value == true
      return "No" if value == false

      value.to_s
    end

    def file_links_for(document, translations)
      scope =
        translations ? document.translated_uploads : document.original_uploads
      scope
        .order(:created_at)
        .select { |upload| upload.attachment.present? }
        .map { |upload| uploaded_document_link(upload) }
        .join(", ")
        .html_safe
    end

    def uploaded_document_link(upload)
      link_to(upload.name, upload.url, target: :_blank, rel: :noopener)
    end
  end
end
