module PageObjects
  module AssessorInterface
    class RequestFurtherInformation < SitePrism::Page
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}/further-information-requests/new"

      element :email_content, "textarea"
    end
  end
end
