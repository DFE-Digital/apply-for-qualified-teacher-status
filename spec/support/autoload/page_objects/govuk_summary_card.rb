# frozen_string_literal: true

module PageObjects
  class GovukSummaryCard < SitePrism::Section
    element :heading, ".govuk-summary-card__title"

    section :actions, ".govuk-summary-card__actions" do
      element :link, ".govuk-link"
    end

    section :summary_list, GovukSummaryList, ".govuk-summary-list"

    def_delegator :summary_list, :rows
    def_delegator :summary_list, :find_row
  end
end
