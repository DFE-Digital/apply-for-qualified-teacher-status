# frozen_string_literal: true

module CheckYourAnswersSummary
  class Component < ApplicationComponent
    def initialize(
      model:,
      id:,
      title:,
      fields:,
      changeable: true,
      with_action_link_to: nil,
      with_action_link_label: nil
    )
      super()
      @model = model
      @id = "app-check-your-answers-summary-#{id}"
      @title = title
      @fields = fields
      @changeable = changeable
      @with_action_link_to = with_action_link_to
      @with_action_link_label = with_action_link_label
    end

    attr_reader :title, :with_action_link_to, :with_action_link_label

    def rows
      fields_with_translations.map { |field| row_for_field(field) }
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
        path.is_a?(String) ? path : url_helpers.polymorphic_path(path)
      end
    end

    def row_for_field(field)
      {
        key: field[:key],
        title: row_title_for(field),
        value:
          format_value(value_for(field), field).presence ||
            "Not provided".html_safe,
        href: changeable ? href_for(field) : nil,
      }
    end

    def format_value(value, field)
      html =
        case value
        when nil
          ""
        when Date
          format_date(value, field)
        when Upload
          helpers.upload_link_to(value)
        when Document
          format_document(value, field)
        when Array
          format_array(value, field)
        when EnglishLanguageProvider
          value.name
        when true
          "Yes"
        when false
          "No"
        else
          value.to_s
        end

      if field[:error]
        "<div class=\"govuk-form-group govuk-form-group--error\">" \
          "<p class=\"govuk-error-message\">#{field[:error_message]}</p>#{html}</div>".html_safe
      elsif field[:highlight]
        "<em class=\"app-highlight\">#{html}</em>".html_safe
      else
        html
      end
    end

    def format_date(date, field)
      field[:format] == :without_day ? date.to_fs(:month_and_year) : date.to_fs
    end

    def format_document(document, field)
      helpers.document_link_to(document, translated: field[:translation])
    end

    def format_array(list, field)
      list.map { |v| format_value(v, field) }.join("<br />").html_safe
    end

    def url_helpers
      @url_helpers ||= Rails.application.routes.url_helpers
    end
  end
end
