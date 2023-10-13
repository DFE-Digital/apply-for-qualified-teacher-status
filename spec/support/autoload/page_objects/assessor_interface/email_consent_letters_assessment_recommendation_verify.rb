# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class EmailConsentLettersAssessmentRecommendationVerify < SitePrism::Page
      set_url "/assessor/applications/{application_form_id}/assessments/{assessment_id}" \
                "/recommendation/verify/email-consent-letters"

      element :heading, "h1"
      element :continue_button, ".govuk-button"
    end
  end
end
