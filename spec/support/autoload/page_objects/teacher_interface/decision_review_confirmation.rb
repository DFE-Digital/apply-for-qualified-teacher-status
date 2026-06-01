# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class DecisionReviewConfirmation < SitePrism::Page
      set_url "/teacher/application/decision-review-requests/{decision_review_request_id}/confirmation"
    end
  end
end
