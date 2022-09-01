module PageObjects
  class Start < Base
    set_url "/eligibility"

    element :heading, "h1"

    element :start_button, "button"

    section :footer, "footer" do
      element :accessibility_link, ".govuk-footer__link", text: "Accessibility"
      element :cookies_link, ".govuk-footer__link", text: "Cookies"
      element :privacy_link, ".govuk-footer__link", text: "Privacy"
    end
  end
end
