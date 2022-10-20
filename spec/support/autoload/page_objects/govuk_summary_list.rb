module PageObjects
  class GovukSummaryList < SitePrism::Section
    sections :rows, ".govuk-summary-list__row" do
      element :key, ".govuk-summary-list__key"
      element :value, ".govuk-summary-list__value"
      section :actions, ".govuk-summary-list__actions" do
        element :link, ".govuk-link"
      end
    end
  end
end
