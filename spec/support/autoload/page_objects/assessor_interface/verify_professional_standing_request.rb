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
        element :submit_button, ".govuk-button"
      end

      def submit_yes
        form.yes_radio_item.choose
        form.submit_button.click
      end

      def submit_no
        form.no_radio_item.choose
        form.submit_button.click
      end
    end
  end
end
