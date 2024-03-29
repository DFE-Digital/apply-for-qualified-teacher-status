module PageObjects
  module AssessorInterface
    class PreviewAssessmentRecommendation < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/recommendation/{recommendation}/preview"

      element :heading, "h1"

      section :email_preview, ".app-email-preview" do
        element :content, ".app-email-preview__content"
      end

      element :send_button, ".govuk-button"
    end
  end
end
