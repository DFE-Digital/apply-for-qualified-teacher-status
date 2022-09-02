require "support/page_objects/govuk_error_summary"

module PageObjects
  module EligibilityInterface
    class Question < SitePrism::Page
      element :heading, "h1"

      section :error_summary, GovukErrorSummary, ".govuk-error-summary"

      section :form, "form" do
        section :yes_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(1)"
        section :no_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(2)"
        element :continue_button, "button"
      end
    end
  end
end
