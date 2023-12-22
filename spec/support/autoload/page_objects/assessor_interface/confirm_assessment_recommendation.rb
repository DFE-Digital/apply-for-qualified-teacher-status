module PageObjects
  module AssessorInterface
    class ConfirmAssessmentRecommendation < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/recommendation/{recommendation}/confirm"

      element :heading, "h1"

      section :form, "form" do
        section :true_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(1)"
        section :false_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(2)"
        element :continue_button, ".govuk-button"
      end
    end
  end
end
