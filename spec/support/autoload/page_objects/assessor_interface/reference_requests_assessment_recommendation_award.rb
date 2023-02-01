# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ReferenceRequestsAssessmentRecommendationAward < SitePrism::Page
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}" \
                "/recommendation/award/reference-requests"

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
