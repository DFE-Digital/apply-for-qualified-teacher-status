# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class VerifyProfessionalStandingRequest < SitePrism::Page
      set_url "/assessor/applications/{application_form_id}/assessments/{assessment_id}" \
                "/professional-standing-request/verify"

      section :form, "form" do
        section :yes_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(1)"
        section :no_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(2)"
        element :failure_reason_textarea, ".govuk-textarea"
        element :submit_button, ".govuk-button"
      end
    end
  end
end
