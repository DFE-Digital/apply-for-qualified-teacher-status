# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class Subjects < SitePrism::Page
      set_url "/teacher/application/subjects"

      element :heading, "h1"

      section :form, "form" do
        element :subject_1_field,
                "#teacher-interface-subjects-form-subject-1-field"
        element :subject_2_field,
                "#teacher-interface-subjects-form-subject-2-field"
        element :subject_3_field,
                "#teacher-interface-subjects-form-subject-3-field"

        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
