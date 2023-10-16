module PageObjects
  module AssessorInterface
    class ConfirmAssessmentRecommendation < SitePrism::Page
      set_url "/assessor/applications/{application_form_id}/assessments/{assessment_id}" \
                "/recommendation/{recommendation}/confirm"

      element :heading, "h1"

      section :form, "form" do
        section :yes_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(1)"
        section :no_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(2)"
        element :continue_button, ".govuk-button"
      end
    end
  end
end
