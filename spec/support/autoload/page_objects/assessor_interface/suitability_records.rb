# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class SuitabilityRecords < SitePrism::Page
      set_url "/assessor/suitability-records"

      element :heading, "h1"

      sections :records, "article" do
        element :heading, "h2"
        element :summary_list, GovukSummaryList, ".govuk-summary-list"
      end
    end
  end
end
