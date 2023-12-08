# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ReviewQualificationRequest < ReviewRequestablePage
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/qualification-requests/{id}/review"
    end
  end
end
