# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class PartOfUniversityDegree < SitePrism::Page
      set_url "/teacher/application/qualifications/{qualification_id}/part_of_university_degree"

      element :heading, "h1"

      section :form, "form" do
        element :part_of_university_degree_true_field,
                "#teacher-interface-part-of-university-degree-form-part-of-university-degree-true-field",
                visible: false
        element :part_of_university_degree_false_field,
                "#teacher-interface-part-of-university-degree-form-part-of-university-degree-false-field",
                visible: false

        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
        element :save_and_come_back_later_button,
                ".govuk-button.govuk-button--secondary"
      end
    end
  end
end
