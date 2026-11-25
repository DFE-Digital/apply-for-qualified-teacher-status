# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class DraftApplication < SitePrism::Page
      set_url "/assessor/draft-applications/{reference}"

      section :header, PageHeader, "body"
      element :back_link, ".govuk-back-link"
      element :main_content, "main"
      element :heading, "h1"
      element :overview_heading, "#app-application-overview h2"
      section :summary_list,
              GovukSummaryList,
              "#app-application-overview .govuk-summary-list"
      elements :change_links, "main a", text: "Change", exact_text: true
      elements :delete_controls,
               "main a, main button",
               text: "Delete application"
    end
  end
end
