# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class SuitabilityRecords < SitePrism::Page
      set_url "/assessor/suitability-records"

      element :heading, "h1"
    end
  end
end
