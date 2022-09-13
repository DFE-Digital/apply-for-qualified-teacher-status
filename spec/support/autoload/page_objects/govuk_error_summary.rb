module PageObjects
  class GovukErrorSummary < SitePrism::Section
    element :title, ".govuk-error-summary__title"
    element :body, ".govuk-error-summary__body"
  end
end
