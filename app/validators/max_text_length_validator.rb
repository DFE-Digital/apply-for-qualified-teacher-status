# frozen_string_literal: true

class MaxTextLengthValidator < ActiveModel::EachValidator
  MAX_LENGTH = 20_000

  def validate_each(record, attribute, value)
    return if value.nil?

    validate_value_does_not_exceed_max_length(record, attribute, value)
  end

  def validate_value_does_not_exceed_max_length(record, attribute, value)
    if value.length > MAX_LENGTH
      record.errors.add attribute, :exceeds_text_max_length
    end
  end
end
