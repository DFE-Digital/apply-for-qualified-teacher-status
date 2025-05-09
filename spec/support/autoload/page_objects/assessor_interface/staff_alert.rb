# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class StaffAlert < SitePrism::Page
      set_url "/assessor/staff/{id}/alert"

      element :heading, "h1.govuk-heading-l"
      element :archive_button, ".govuk-button"
      element :cancel_link, ".govuk-link"
    end
  end
end
