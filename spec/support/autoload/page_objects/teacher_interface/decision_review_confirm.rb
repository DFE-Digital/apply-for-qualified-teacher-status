# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class DecisionReviewSummaryCard < GovukSummaryCard
      element :heading, "h2"
    end

    class DecisionReviewConfirm < SitePrism::Page
      set_url "/teacher/application/decision-review-requests/{decision_review_request_id}/confirm"

      sections :summary_rows, DecisionReviewSummaryCard, ".govuk-summary-card"

      section :form, "form" do
        element :submit_button, ".govuk-button"
      end
    end
  end
end
