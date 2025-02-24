# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class PassportExpiryDate < SitePrism::Page
      set_url "/teacher/application/passport_document/expiry_date"

      element :heading, "h1"

      section :form, "form" do
        element :passport_country_of_issue_code,
                'input[name="passport_country_of_issue_autocomplete"]'
        element :passport_expiry_date_day_field,
                "#teacher_interface_passport_expiry_date_form_passport_expiry_date_3i"
        element :passport_expiry_date_month_field,
                "#teacher_interface_passport_expiry_date_form_passport_expiry_date_2i"
        element :passport_expiry_date_year_field,
                "#teacher_interface_passport_expiry_date_form_passport_expiry_date_1i"

        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
