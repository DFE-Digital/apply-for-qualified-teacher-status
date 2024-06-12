# frozen_string_literal: true

module PageObjects
  class GovukErrorSummary < SitePrism::Section
    element :heading, ".govuk-error-summary__title"
    element :body, ".govuk-error-summary__body"
  end
end
