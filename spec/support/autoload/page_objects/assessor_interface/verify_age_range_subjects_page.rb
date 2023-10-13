# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class AgeRangeSubjectCard < SitePrism::Section
      element :heading, "h2"
    end

    class VerifyAgeRangeSubjectsPage < AssessmentSection
      set_url "/assessor/applications/{application_form_id}/assessments/{assessment_id}/sections/{section_id}"

      sections :cards, AgeRangeSubjectCard, ".govuk-summary-card"

      section :age_range_form, "form" do
        element :minimum,
                "#assessor-interface-assessment-section-form-age-range-min-field"
        element :maximum,
                "#assessor-interface-assessment-section-form-age-range-max-field"
        element :note,
                "#assessor-interface-assessment-section-form-age-range-note-field"
      end

      section :subjects_form, "form" do
        element :first_field,
                "#assessor-interface-assessment-section-form-subject-1-field"
        element :second_field,
                "#assessor-interface-assessment-section-form-subject-2-field"
        element :third_field,
                "#assessor-interface-assessment-section-form-subject-3-field"
        element :note_textarea,
                "#assessor-interface-assessment-section-form-subjects-note-field"
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
