# frozen_string_literal: true

module PageObjects
  class GovukSummaryListCard < SitePrism::Section
    element :title, ".govuk-summary-list__card-title"

    section :actions, ".govuk-summary-list__card-actions" do
      sections :items, ".govuk-summary-list__card-actions-list-item" do
        element :link, ".govuk-link"
      end
    end

    section :summary_list, GovukSummaryList, ".govuk-summary-list"

    def_delegator :summary_list, :rows
    def_delegator :summary_list, :find_row
  end
end
