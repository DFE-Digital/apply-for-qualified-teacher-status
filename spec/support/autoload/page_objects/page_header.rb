# frozen_string_literal: true

module PageObjects
  class PageHeader < SitePrism::Section
    element :search_link, "a.govuk-header__link", text: "Search"
    element :sign_out_link, "a.govuk-header__link", text: "Sign out"
    element :manage_access_link, "a.govuk-header__link", text: "Manage access"
    element :support_console_link,
            "a.govuk-header__link",
            text: "Support console"
  end
end
