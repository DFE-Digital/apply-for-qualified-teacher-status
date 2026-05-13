# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class DecisionReviewConfirmation < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/decision-review-requests/{decision_review_request_id}/confirmation"
    end
  end
end
