module PageObjects
  module AssessorInterface
    class RequestFurtherInformation < SitePrism::Page
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}/further-information-requests/preview"

      sections :items, ".app-further-information-request-item" do
        element :heading, ".govuk-heading-s"
        element :assessor_notes, ".govuk-inset-text"
      end

      element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      element :back_to_overview_button, ".govuk-button.govuk-button--secondary"
    end
  end
end
