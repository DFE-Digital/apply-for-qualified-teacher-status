# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class StaffIndex < SitePrism::Page
      set_url "/assessor/staff"

      element :heading, "h1.govuk-heading-l"
    end
  end
end
