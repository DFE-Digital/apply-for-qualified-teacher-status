# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class VerifyQualificationRequest < VerifyRequestablePage
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/qualification-requests/{id}/verify"
    end
  end
end
