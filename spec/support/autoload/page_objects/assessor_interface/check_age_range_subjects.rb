# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class AgeRangeSubjectCard < SitePrism::Section
      element :heading, "h2"
    end

    class CheckAgeRangeSubjects < AssessmentSection
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}/sections/age_range_subjects"

      sections :cards, AgeRangeSubjectCard, ".govuk-summary-list__card"

      def age_range
        cards&.first
      end

      def subjects
        cards&.second
      end
    end
  end
end
