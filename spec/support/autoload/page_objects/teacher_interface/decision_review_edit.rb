# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class DecisionReviewEdit < SitePrism::Page
      set_url "/teacher/application/decision-review-requests/{decision_review_request_id}/edit"

      section :form, "form" do
        element :submit_button, ".govuk-button"
      end
    end
  end
end
