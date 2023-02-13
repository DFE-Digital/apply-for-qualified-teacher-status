# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class RegistrationNumber < SitePrism::Page
      set_url "/teacher/application/registration_number"

      element :heading, "h1"

      section :form, "form" do
        element :registration_number_field,
                "#teacher-interface-registration-number-form-registration-number-field"
        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
