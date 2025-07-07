# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class PrioritisationReferencesConfirmation < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/prioritisation-reference-requests/confirmation"
    end
  end
end
