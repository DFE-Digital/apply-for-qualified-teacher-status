# frozen_string_literal: true

module PageObjects
  class PageHeader < SitePrism::Section
    element :applications_link,
            "a.govuk-service-navigation__link",
            text: "Applications"
    element :sign_out_link, "a.govuk-link--inverse", text: "Sign out"
    element :support_console_link,
            "a.govuk-service-navigation__link",
            text: "Support console"
    element :service_feedback_link,
            "a.govuk-service-navigation__link",
            text: "Service feedback"
  end
end
