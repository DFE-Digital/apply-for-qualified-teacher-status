# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class StaffUnarchive < SitePrism::Page
      set_url "/assessor/staff/{id}/unarchive"

      element :heading, "h1.govuk-heading-l"
      element :reactivate_button, ".govuk-button"
      element :cancel_link, ".govuk-link"
    end
  end
end
