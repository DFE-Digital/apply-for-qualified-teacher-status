# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ReferenceRequestsAssessmentRecommendationVerify < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/recommendation/verify/reference-requests"

      element :heading, "h1"

      section :form, "form" do
        sections :work_history_checkboxes,
                 GovukCheckboxItem,
                 ".govuk-checkboxes__item"
        element :submit_button, ".govuk-button"
      end
    end
  end
end
