# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ContactProfessionalStandingAssessmentRecommendationVerify < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/recommendation/verify/contact-professional-standing"

      element :heading, "h1"
      element :continue_button, ".govuk-button"
    end
  end
end
