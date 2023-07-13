# frozen_string_literal: true

module TagHelper
  def govuk_boolean_tag(value)
    if value
      govuk_tag(text: "Yes", colour: "green")
    else
      govuk_tag(text: "No", colour: "red")
    end
  end
end
