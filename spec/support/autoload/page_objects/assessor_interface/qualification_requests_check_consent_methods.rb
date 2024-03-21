# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class QualificationRequestsCheckConsentMethods < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/qualification-requests/check-consent-methods"

      element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
    end
  end
end
