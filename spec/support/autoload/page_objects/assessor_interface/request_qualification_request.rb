# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class RequestQualificationRequest < RequestRequestablePage
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/qualification-requests/{id}/request"
    end
  end
end
