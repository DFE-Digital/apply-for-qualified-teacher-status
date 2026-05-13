# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ConfirmDecisionReview < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/decision-review-requests/{decision_review_request_id}/confirm"

      section :form, "form" do
        element :submit_button, ".govuk-button"
      end
    end
  end
end
