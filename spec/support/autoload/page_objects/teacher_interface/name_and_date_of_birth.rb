# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class NameAndDateOfBirth < SitePrism::Page
      set_url "/teacher/application/personal_information/name_and_date_of_birth"

      element :heading, "h1"

      section :form, "form" do
        element :given_names_field,
                "#teacher-interface-name-and-date-of-birth-form-given-names-field"
        element :family_name_field,
                "#teacher-interface-name-and-date-of-birth-form-family-name-field"
        element :date_of_birth_day_field,
                "#teacher_interface_name_and_date_of_birth_form_date_of_birth_3i"
        element :date_of_birth_month_field,
                "#teacher_interface_name_and_date_of_birth_form_date_of_birth_2i"
        element :date_of_birth_year_field,
                "#teacher_interface_name_and_date_of_birth_form_date_of_birth_1i"

        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
