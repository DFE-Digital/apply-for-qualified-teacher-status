require "support/page_objects/govuk_error_summary"

module PageObjects
  module EligibilityInterface
    class Country < SitePrism::Page
      set_url "/eligibility/countries"

      element :heading, "h1"

      section :error_summary, GovukErrorSummary, ".govuk-error-summary"

      section :form, "form" do
        element :location_field, 'input[name="location_autocomplete"]'
        element :continue_button, "button"
      end
    end
  end
end
