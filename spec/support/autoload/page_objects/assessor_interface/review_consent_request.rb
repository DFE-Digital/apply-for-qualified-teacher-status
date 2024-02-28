# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ReviewConsentRequest < ReviewRequestablePage
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/consent-requests/{id}/review"
    end
  end
end
