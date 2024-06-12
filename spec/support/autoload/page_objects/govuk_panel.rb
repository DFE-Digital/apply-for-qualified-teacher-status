# frozen_string_literal: true

module PageObjects
  class GovukPanel < SitePrism::Section
    element :heading, ".govuk-panel__title"
    element :body, ".govuk-panel__body"
  end
end
