# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class VerifyFailedReferenceRequest < VerifyFailedRequestablePage
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/reference-requests/{id}/verify-failed"
    end
  end
end
