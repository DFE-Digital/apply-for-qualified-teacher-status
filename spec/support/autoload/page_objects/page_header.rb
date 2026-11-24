# frozen_string_literal: true

module PageObjects
  class PageHeader < SitePrism::Section
    element :applications_link,
            "a.govuk-service-navigation__link",
            text: "Applications"
    element :submitted_link,
            "#sub-navigation a.govuk-service-navigation__link",
            text: "Submitted"
    element :drafts_link,
            "#sub-navigation a.govuk-service-navigation__link",
            text: "Drafts"
    element :active_applications_link,
            ".govuk-service-navigation__item--active a",
            text: "Applications",
            exact_text: true
    element :active_submitted_link,
            "#sub-navigation .govuk-service-navigation__item--active a",
            text: "Submitted"
    element :active_drafts_link,
            "#sub-navigation .govuk-service-navigation__item--active a",
            text: "Drafts"
    element :sign_out_link, "a.govuk-link--inverse", text: "Sign out"
    element :support_console_link,
            "a.govuk-service-navigation__link",
            text: "Support console"
    element :service_feedback_link,
            "a.govuk-service-navigation__link",
            text: "Service feedback"
  end
end
