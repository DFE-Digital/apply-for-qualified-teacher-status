# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class EditAgeRangeSubjectsAssessmentRecommendationAward < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/recommendation/award/age-range-subjects/edit"

      element :heading, "h1"

      section :form, "form" do
        element :age_range_minimum_field,
                "#assessor-interface-confirm-age-range-subjects-form-age-range-min-field"
        element :age_range_maximum_field,
                "#assessor-interface-confirm-age-range-subjects-form-age-range-max-field"
        element :age_range_note_field,
                "#assessor-interface-confirm-age-range-subjects-form-age-range-note-field"

        element :subjects_first_field,
                "#assessor-interface-confirm-age-range-subjects-form-subject-1-field"
        element :subjects_second_field,
                "#assessor-interface-confirm-age-range-subjects-form-subject-2-field"
        element :subjects_third_field,
                "#assessor-interface-confirm-age-range-subjects-form-subject-3-field"
        element :subjects_note_field,
                "#assessor-interface-confirm-age-range-subjects-form-subjects-note-field"

        element :submit_button, "button"
      end
    end
  end
end
