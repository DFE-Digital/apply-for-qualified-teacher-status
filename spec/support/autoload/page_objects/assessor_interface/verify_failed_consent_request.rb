# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class VerifyFailedConsentRequest < VerifyFailedRequestablePage
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/consent-requests/{id}/verify-failed"
    end
  end
end
