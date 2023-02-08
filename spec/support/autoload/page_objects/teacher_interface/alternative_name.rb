# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class AlternativeName < SitePrism::Page
      set_url "/teacher/application/personal_information/alternative_name"

      element :heading, "h1"

      section :form, "form" do
        element :has_alternative_name_true_field,
                "#teacher-interface-alternative-name-form-has-alternative-name-true-field",
                visible: false
        element :has_alternative_name_false_field,
                "#teacher-interface-alternative-name-form-has-alternative-name-false-field",
                visible: false

        element :alternative_given_names_field,
                "#teacher-interface-alternative-name-form-alternative-given-names-field"
        element :alternative_family_name_field,
                "#teacher-interface-alternative-name-form-alternative-family-name-field"

        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
