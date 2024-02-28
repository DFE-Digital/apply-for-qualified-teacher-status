# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class VerifyFailedQualificationRequest < VerifyFailedRequestablePage
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/qualification-requests/{id}/verify-failed"
    end
  end
end
