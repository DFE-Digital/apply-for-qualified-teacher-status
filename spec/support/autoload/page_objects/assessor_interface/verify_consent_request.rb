# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class VerifyConsentRequest < VerifyRequestablePage
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/consent-requests/{id}/verify"

      element :download_original_button,
              ".govuk-button:not(.govuk-button--inverse)"
      element :download_as_pdf_button, ".govuk-button.govuk-button--inverse"
    end
  end
end
