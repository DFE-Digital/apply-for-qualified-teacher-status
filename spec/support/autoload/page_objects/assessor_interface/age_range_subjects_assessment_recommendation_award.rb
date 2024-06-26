# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class AgeRangeSubjectsAssessmentRecommendationAward < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/recommendation/award/age-range-subjects"

      element :heading, "h1"
      section :summary_list, GovukSummaryList, ".govuk-summary-list"
      element :continue_button, ".govuk-button"
    end
  end
end
