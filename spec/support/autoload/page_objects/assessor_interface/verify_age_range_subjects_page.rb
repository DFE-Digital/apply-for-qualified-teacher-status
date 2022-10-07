# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class AgeRangeSubjectCard < SitePrism::Section
      element :heading, "h2"
    end

    class VerifyAgeRangeSubjectsPage < AssessmentSection
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}/sections/age_range_subjects"

      sections :cards, AgeRangeSubjectCard, ".govuk-summary-list__card"

      section :age_range_form, "form" do
        element :minimum,
                "#assessor-interface-assessment-section-form-age-range-min-field"
        element :maximum,
                "#assessor-interface-assessment-section-form-age-range-max-field"
        element :note,
                "#assessor-interface-assessment-section-form-age-range-note-field"
      end

      def age_range
        cards&.first
      end

      def subjects
        cards&.second
      end
    end
  end
end
