# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class QualificationRequestsAssessmentRecommendationVerify < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/recommendation/verify/qualification-requests"

      element :heading, "h1"

      section :form, "form" do
        sections :qualification_checkboxes,
                 GovukCheckboxItem,
                 ".govuk-checkboxes__item"
        element :submit_button, ".govuk-button"
      end
    end
  end
end
