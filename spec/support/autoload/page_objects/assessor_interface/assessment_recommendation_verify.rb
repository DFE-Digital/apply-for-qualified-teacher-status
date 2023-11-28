# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class AssessmentRecommendationVerify < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/recommendation/verify/edit"

      element :submit_button, ".govuk-button"
    end
  end
end
