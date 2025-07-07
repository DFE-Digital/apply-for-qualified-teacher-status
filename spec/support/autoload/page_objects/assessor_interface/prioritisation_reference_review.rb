# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class PrioritisationReferenceReview < ReviewRequestablePage
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/prioritisation-reference-requests/{prioritisation_reference_request_id}/edit"
    end
  end
end
