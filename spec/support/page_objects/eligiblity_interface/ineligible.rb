module PageObjects
  module EligibilityInterface
    class Ineligible < SitePrism::Page
      set_url "/eligibility/ineligible"

      element :heading, "h1"
      element :description, ".govuk-body", match: :first
      element :reasons, ".govuk-list"
    end
  end
end
