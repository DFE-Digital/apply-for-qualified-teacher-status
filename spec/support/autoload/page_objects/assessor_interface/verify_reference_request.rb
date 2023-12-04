# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class VerifyReferenceRequest < VerifyRequestablePage
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/reference-requests/{id}/verify"

      section :summary_list, GovukSummaryList, "#reference-details-summary-list"

      section :responses, ".govuk-summary-card" do
        element :heading, ".govuk-summary-card__title"
        elements :keys, ".govuk-summary-list__key"
        elements :values, ".govuk-summary-list__value"
      end
    end
  end
end
