class CheckYourAnswersSummaryComponent < ViewComponent::Base
  def initialize(model:, title:, fields:)
    super
    @model = model
    @title = title
    @fields = fields
  end

  attr_reader :title

  def rows
    fields.map { |key, opts| opts ? row_for_field(key, opts) : nil }.compact
  end

  private

  def row_for_field(key, opts)
    {
      key: opts.fetch(:key, key.to_s.humanize),
      value: format_value(model.send(key), opts),
      href: opts.fetch(:href)
    }
  end

  def format_value(value, opts)
    return "" if value.nil?

    if value.is_a?(Date)
      format = opts[:format] == :without_day ? "%B %Y" : "%e %B %Y"
      return value.strftime(format).strip
    end

    if value.is_a?(Document)
      return(
        value
          .uploads
          .order(:created_at)
          .map { |upload| upload.attachment&.filename }
          .compact
          .join(", ")
      )
    end

    return "Yes" if value == true
    return "No" if value == false

    value.to_s
  end

  attr_reader :model, :fields
end
