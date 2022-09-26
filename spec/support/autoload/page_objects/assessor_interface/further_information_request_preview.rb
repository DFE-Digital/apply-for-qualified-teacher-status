module PageObjects
  module AssessorInterface
    class FurtherInformationRequestPreview < SitePrism::Page
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}" \
                "/further-information-requests/{further_information_request_id}"

      element :email_preview, "div.app-email-preview"
    end
  end
end
