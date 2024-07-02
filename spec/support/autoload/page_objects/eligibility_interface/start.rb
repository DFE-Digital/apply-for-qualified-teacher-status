# frozen_string_literal: true

module PageObjects
  module EligibilityInterface
    class Start < SitePrism::Page
      set_url "/eligibility/start"

      element :heading, "h1"
      element :description, ".govuk-body", match: :first

      element :start_button, "button"

      section :footer, "footer" do
        element :accessibility_link,
                ".govuk-footer__link",
                text: "Accessibility"
        element :cookies_link, ".govuk-footer__link", text: "Cookies"
        element :privacy_link, ".govuk-footer__link", text: "Privacy"
      end
    end
  end
end
