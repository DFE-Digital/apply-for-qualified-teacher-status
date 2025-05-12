# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class StaffIndex < SitePrism::Page
      set_url "/assessor/staff"

      element :heading, "h1.govuk-heading-l"
      element :archive_user_button, ".govuk-button"
      element :archived_users_tab,
              'li.govuk-tabs__list-item a[href="#archived-users"]'
    end
  end
end
