require "support/page_objects/govuk_error_summary"

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
    end
  end
end
