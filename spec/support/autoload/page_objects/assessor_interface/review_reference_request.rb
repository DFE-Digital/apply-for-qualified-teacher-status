# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ReviewReferenceRequest < ReviewRequestablePage
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/reference-requests/{id}/review"
    end
  end
end
