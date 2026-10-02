# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class FeedbackSubmission < SitePrism::Page
      set_url "/assessor/feedback/{id}"

      section :summary_list, GovukSummaryList, ".govuk-summary-list"
      element :comments, "h2 + .govuk-body"
      element :back_link, "a.govuk-back-link"
    end
  end
end
