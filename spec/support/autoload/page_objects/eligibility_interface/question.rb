# frozen_string_literal: true

module PageObjects
  module EligibilityInterface
    class Question < SitePrism::Page
      element :heading, "h1"

      section :error_summary, GovukErrorSummary, ".govuk-error-summary"

      section :form, "form" do
        sections :radio_items,
                 PageObjects::GovukRadioItem,
                 ".govuk-radios__item"
        section :true_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(1)"
        section :false_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(2)"
        element :continue_button, "button"
      end

      def submit_yes
        form.true_radio_item.input.click
        form.continue_button.click
      end

      def submit_no
        form.false_radio_item.input.click
        form.continue_button.click
      end
    end
  end
end
