module PageObjects
  module AssessorInterface
    class ReviewFurtherInformationRequest < SitePrism::Page
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}" \
                "/further-information-requests/{further_information_request_id}/edit"

      element :heading, ".govuk-heading-xl"
      section :summary_list, GovukSummaryList, ".govuk-summary-list"
    end
  end
end
