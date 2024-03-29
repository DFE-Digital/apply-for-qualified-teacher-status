# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ReviewProfessionalStandingRequest < ReviewRequestablePage
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/professional-standing-request/review"
    end
  end
end
