# frozen_string_literal: true

module PageObjects
  module SupportInterface
    class StaffIndex < SitePrism::Page
      set_url "/support/staff"

      element :heading, "h1.govuk-heading-l"
    end
  end
end
