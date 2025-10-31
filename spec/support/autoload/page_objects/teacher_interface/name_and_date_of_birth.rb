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

        element :national_insurance_number_part_one_field,
                "#teacher-interface-name-and-date-of-birth-form-national-insurance-number-part-one"
        element :national_insurance_number_part_two_field,
                "#teacher-interface-name-and-date-of-birth-form-national-insurance-number-part-two"
        element :national_insurance_number_part_three_field,
                "#teacher-interface-name-and-date-of-birth-form-national-insurance-number-part-three"

        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
