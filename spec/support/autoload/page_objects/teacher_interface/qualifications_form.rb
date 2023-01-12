module PageObjects
  module TeacherInterface
    class QualificationsForm < SitePrism::Page
      element :heading, "h1"
      elements :body, ".govuk-body-l"

      section :form, "form" do
        element :title, "#teacher-interface-qualification-form-title-field"
        element :institution_name,
                "#teacher-interface-qualification-form-institution-name-field"
        element :institution_country,
                "#teacher-interface-qualification-form-institution-country-location-field"
        element :start_date_month,
                "#teacher_interface_qualification_form_start_date_2i"
        element :start_date_year,
                "#teacher_interface_qualification_form_start_date_1i"
        element :complete_date_month,
                "#teacher_interface_qualification_form_complete_date_2i"
        element :complete_date_year,
                "#teacher_interface_qualification_form_complete_date_1i"
        element :certificate_date_month,
                "#teacher_interface_qualification_form_certificate_date_2i"
        element :certificate_date_year,
                "#teacher_interface_qualification_form_certificate_date_1i"

        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
        element :save_and_come_back_later_button,
                ".govuk-button.govuk-button--secondary"
      end
    end
  end
end
