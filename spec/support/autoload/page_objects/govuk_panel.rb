module PageObjects
  class GovukPanel < SitePrism::Section
    element :title, ".govuk-panel__title"
    element :body, ".govuk-panel__body"
  end
end
