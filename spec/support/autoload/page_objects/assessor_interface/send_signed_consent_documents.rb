# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class SendSignedConsentDocuments < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/consent-requests/request"

      element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
    end
  end
end
