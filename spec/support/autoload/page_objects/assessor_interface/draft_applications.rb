# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class DraftApplications < SitePrism::Page
      set_url "/assessor/applications/drafts"

      section :header, PageHeader, "body"

      element :heading, "h1"
      element :email_label, "label"
      element :email_hint, "#draft-email-hint"
      element :email, "input[type=text]"
      element :search, "button", text: "Search", exact_text: true
      element :clear_search, "a", text: "Clear search results"
      element :result_count, "h2", text: /results? for/
      element :empty_state,
              "h2",
              text:
                "No applications found. Use the search bar above to try again or refine your search"

      sections :search_results, ".app-search-results__item" do
        element :email, "h2 a"
        elements :summary_keys, ".app-description-list dt"
        elements :summary_values, ".app-description-list dd"

        def summary_value(key)
          index = summary_keys.map(&:text).index(key)
          summary_values[index].text if index
        end
      end

      section :pagination, "nav.govuk-pagination" do
        element :next, "a", text: "Next"
        element :previous, "a", text: "Previous"
      end

      def search_for(value)
        email.set(value)
        search.click
      end
    end
  end
end
