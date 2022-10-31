module PageObjects
  module AssessorInterface
    class DeclareAssessmentRecommendation < SitePrism::Page
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}/declare"

      element :heading, "h1"

      sections :failure_reason_lists, ".govuk-list" do
        sections :items, "li" do
          element :heading, ".govuk-heading-s"
          element :note, ".govuk-inset-text"
        end
      end

      section :form, "form" do
        element :declaration_checkbox,
                ".govuk-checkboxes__input",
                visible: false
        element :submit_button, ".govuk-button"
      end
    end
  end
end
