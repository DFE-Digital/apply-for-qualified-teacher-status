module PageObjects
  module EligibilityInterface
    class Eligible < SitePrism::Page
      set_url "/eligibility/eligible"

      element :heading, "h1"
      element :apply_button, ".govuk-button"
    end
  end
end
