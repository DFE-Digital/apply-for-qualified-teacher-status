# frozen_string_literal: true

module PageObjects
  module EligibilityInterface
    class Region < SitePrism::Page
      set_url "/eligibility/region"

      element :heading, "h1"

      section :error_summary, GovukErrorSummary, ".govuk-error-summary"

      section :form, "form" do
        sections :radio_items,
                 PageObjects::GovukRadioItem,
                 ".govuk-radios__item"
        element :continue_button, "button"
      end

      def submit(region:)
        form.radio_items.find { |e| e.text == region }.input.click
        form.continue_button.click
      end
    end
  end
end
