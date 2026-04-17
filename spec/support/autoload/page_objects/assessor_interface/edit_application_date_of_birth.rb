# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class EditApplicationDateOfBirth < SitePrism::Page
      set_url "/assessor/applications/{reference}/date-of-birth"

      section :form, "form" do
        element :day_field,
                "#assessor_interface_application_form_date_of_birth_form_date_of_birth_3i"
        element :month_field,
                "#assessor_interface_application_form_date_of_birth_form_date_of_birth_2i"
        element :year_field,
                "#assessor_interface_application_form_date_of_birth_form_date_of_birth_1i"
        element :save_button, "govuk-button"
      end
    end
  end
end
