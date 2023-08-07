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
      @delete_link_to if changeable && @delete_link_to
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
      return if (path = field[:href]).blank?

      return path if path.is_a?(String)

      Rails.application.routes.url_helpers.polymorphic_path(path)
    end

    def row_for_field(field)
      {
        key: field[:key],
        title: row_title_for(field),
        value:
          format_value(value_for(field), field).presence ||
            "<em>None provided</em>".html_safe,
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

      if field[:highlight]
        "<em class=\"app-highlight\">#{html}</em>".html_safe
      else
        html
      end
    end

    def format_date(date, field)
      format = field[:format] == :without_day ? "%B %Y" : "%e %B %Y"
      date.strftime(format).strip
    end

    def format_document(document, field)
      scope =
        (
          if field[:translation]
            document.translated_uploads
          else
            document.original_uploads
          end
        )

      if document.optional? && !document.available
        "<em>The applicant has indicated that they haven't done an induction period " \
          "and don't have this document.</em>".html_safe
      else
        uploads =
          scope
            .order(:created_at)
            .select { |upload| upload.attachment.present? }

        malware_scan_active =
          FeatureFlags::FeatureFlag.active?(:fetch_malware_scan_result)

        [
          format_array(uploads, field),
          if malware_scan_active && scope.scan_result_suspect.exists?
            "<em>One or more upload has been deleted by the virus scanner.</em>"
          end,
        ].compact_blank.join("<br /><br />").html_safe
      end
    end

    def format_array(list, field)
      list.map { |v| format_value(v, field) }.join("<br />").html_safe
    end
  end
end
