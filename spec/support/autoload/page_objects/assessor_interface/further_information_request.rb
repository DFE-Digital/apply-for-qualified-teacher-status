module PageObjects
  module AssessorInterface
    class FurtherInformationRequest < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/further-information-requests/{further_information_request_id}"
    end
  end
end
