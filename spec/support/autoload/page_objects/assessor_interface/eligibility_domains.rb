# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class EligibilityDomains < SitePrism::Page
      set_url "/assessor/eligibility-domains"

      element :heading, "h1"

      element :add_new_entry_button, ".govuk-button"

      sections :records, "article" do
        section :heading, "h2.govuk-heading-m" do
          element :link, "a"
        end

        element :summary_list, GovukSummaryList, ".govuk-summary-list"
        element :view_history_details_link, ".govuk-details__summary-text"
        element :history_details, ".moj-timeline"
      end
    end
  end
end
