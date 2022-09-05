require_relative "../govuk_error_summary"
require_relative "../govuk_radio_item"

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

      def submit_yes
        form.yes_radio_item.input.click
        form.continue_button.click
      end

      def submit_no
        form.no_radio_item.input.click
        form.continue_button.click
      end
    end
  end
end
