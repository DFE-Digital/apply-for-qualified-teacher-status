# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class GhanaRegistrationNumber < SitePrism::Page
      set_url "/teacher/application/registration_number"

      element :heading, "h1"

      section :form, "form" do
        element :license_number_part_one_field,
                "#teacher-interface-ghana-registration-number-form-license-number-part-one"
        element :license_number_part_two_field,
                "#teacher-interface-ghana-registration-number-form-license-number-part-two"
        element :license_number_part_three_field,
                "#teacher-interface-ghana-registration-number-form-license-number-part-three"
        element :license_number_error_message,
                "#teacher-interface-ghana-registration-number-form-registration-number-field-error"
        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
