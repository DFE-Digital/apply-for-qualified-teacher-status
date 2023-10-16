module PageObjects
  module AssessorInterface
    class FurtherInformationRequestPreview < SitePrism::Page
      set_url "/assessor/applications/{application_form_id}/assessments/{assessment_id}" \
                "/further-information-requests/new"

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
