module PageObjects
  module AssessorInterface
    class FurtherInformationRequestPreview < SitePrism::Page
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}" \
                "/further-information-requests/{further_information_request_id}/edit"

      element :email_preview, "div.app-email-preview"

      section :form, "form" do
        element :send_to_applicant_button,
                ".govuk-button:not(.govuk-button--secondary)"
        element :back_to_overview_button,
                ".govuk-button.govuk-button--secondary"
      end
    end
  end
end
