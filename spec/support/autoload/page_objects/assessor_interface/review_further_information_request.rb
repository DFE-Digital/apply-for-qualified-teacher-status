# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ReviewFurtherInformationRequest < ReviewRequestablePage
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/further-information-requests/{id}/edit"

      element :heading, ".govuk-heading-xl"
      sections :summary_lists, GovukSummaryList, ".govuk-summary-list"
    end
  end
end
