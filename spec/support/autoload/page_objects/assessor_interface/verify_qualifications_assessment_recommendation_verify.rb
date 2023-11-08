# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class VerifyQualificationsAssessmentRecommendationVerify < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/recommendation/verify/verify-qualifications"

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
