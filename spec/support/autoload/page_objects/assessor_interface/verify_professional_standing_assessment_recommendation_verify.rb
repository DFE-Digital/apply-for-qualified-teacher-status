# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class VerifyProfessionalStandingAssessmentRecommendationVerify < SitePrism::Page
      set_url "/assessor/applications/{application_form_id}/assessments/{assessment_id}" \
                "/recommendation/verify/verify-professional-standing"

      element :heading, "h1"

      section :form, "form" do
        section :yes_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(1)"
        section :no_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(2)"

        element :submit_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
