# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class NewOtherEnglandWorkHistory < SitePrism::Page
      set_url "/teacher/application/other_england_work_histories/new"

      section :form, "form" do
        element :school_name_input,
                "#teacher-interface-other-england-work-history-school-form-school-name-field"
        element :address_line1_input,
                "#teacher-interface-other-england-work-history-school-form-address-line1-field"
        element :address_line2_input,
                "#teacher-interface-other-england-work-history-school-form-address-line2-field"
        element :city_input,
                "#teacher-interface-other-england-work-history-school-form-city-field"
        element :country_input,
                "#teacher-interface-other-england-work-history-school-form-country-location-field"
        element :postcode_input,
                "#teacher-interface-other-england-work-history-school-form-postcode-field"
        element :school_website_input,
                "#teacher-interface-other-england-work-history-school-form-school-website-field"

        element :job_input,
                "#teacher-interface-other-england-work-history-school-form-job-field"

        element :start_date_month_input,
                "#teacher_interface_other_england_work_history_school_form_start_date_2i"
        element :start_date_year_input,
                "#teacher_interface_other_england_work_history_school_form_start_date_1i"

        sections :still_employed_radio_items,
                 GovukRadioItem,
                 ".govuk-radios__item"

        element :end_date_month_input,
                "#teacher_interface_other_england_work_history_school_form_end_date_2i"
        element :end_date_year_input,
                "#teacher_interface_other_england_work_history_school_form_end_date_1i"

        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
        element :save_and_come_back_later_button,
                ".govuk-button.govuk-button--secondary"
      end
    end
  end
end
