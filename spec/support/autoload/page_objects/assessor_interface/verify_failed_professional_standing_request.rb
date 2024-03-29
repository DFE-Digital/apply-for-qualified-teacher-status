# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class VerifyFailedProfessionalStandingRequest < VerifyFailedRequestablePage
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/professional-standing-request/verify-failed"
    end
  end
end
