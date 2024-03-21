# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class RequestProfessionalStandingRequest < RequestRequestablePage
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/professional-standing-request/request"
    end
  end
end
