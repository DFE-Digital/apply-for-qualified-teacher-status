# frozen_string_literal: true

module PageObjects
  module EligibilityInterface
    class Eligible < SitePrism::Page
      set_url "/eligibility/result"

      element :heading, "h1"
      element :apply_button, ".govuk-button"
    end
  end
end
