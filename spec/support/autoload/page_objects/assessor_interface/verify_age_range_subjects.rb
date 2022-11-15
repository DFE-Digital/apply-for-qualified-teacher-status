# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class VerifyAgeRangeSubjects < AssessmentSection
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}/age_range_subjects/edit"

      element :heading, "h1"

      section :form, "form" do
        element :age_range_minimum,
                "#assessor-interface-age-range-subjects-form-age-range-min-field"
        element :age_range_maximum,
                "#assessor-interface-age-range-subjects-form-age-range-max-field"
        element :age_range_note,
                "#assessor-interface-age-range-subjects-form-age-range-note-field"

        element :subjects_first_field,
                "#assessor-interface-age-range-subjects-form-subject-1-field"
        element :subjects_second_field,
                "#assessor-interface-age-range-subjects-form-subject-2-field"
        element :subjects_third_field,
                "#assessor-interface-age-range-subjects-form-subject-3-field"
        element :subjects_note_textarea,
                "#assessor-interface-age-range-subjects-form-subjects-note-field"

        element :continue_button, "button"
      end
    end
  end
end
