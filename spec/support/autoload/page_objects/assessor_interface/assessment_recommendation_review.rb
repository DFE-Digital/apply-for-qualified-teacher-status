# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class AssessmentRecommendationReview < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/recommendation/review/edit"

      element :continue_button, ".govuk-button"
    end
  end
end
