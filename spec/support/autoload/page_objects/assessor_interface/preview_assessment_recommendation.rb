module PageObjects
  module AssessorInterface
    class PreviewAssessmentRecommendation < SitePrism::Page
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}/preview"

      element :heading, "h1"

      section :form, "form" do
        element :send_button, ".govuk-button"
      end
    end
  end
end
