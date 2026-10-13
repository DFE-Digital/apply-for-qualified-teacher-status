# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class WorkHistorySchoolForm < SitePrism::Page
      element :meets_all_requirements_checkbox,
              "#teacher-interface-work-history-school-form-meets-all-requirements-1-field",
              visible: false

      element :school_name_input,
              "#teacher-interface-work-history-school-form-school-name-field"
      element :address_line1_input,
              "#teacher-interface-work-history-school-form-address-line1-field"
      element :address_line2_input,
              "#teacher-interface-work-history-school-form-address-line2-field"
      element :city_input,
              "#teacher-interface-work-history-school-form-city-field"
      element :country_input,
              "#teacher-interface-work-history-school-form-country-location-field"
      element :postcode_input,
              "#teacher-interface-work-history-school-form-postcode-field"
      element :school_website_input,
              "#teacher-interface-work-history-school-form-school-website-field"

      element :job_input,
              "#teacher-interface-work-history-school-form-job-field"

      element :hours_per_week_input,
              "#teacher-interface-work-history-school-form-hours-per-week-field"

      element :start_date_month_input,
              "#teacher_interface_work_history_school_form_start_date_2i"
      element :start_date_year_input,
              "#teacher_interface_work_history_school_form_start_date_1i"
      element :start_date_is_input_checkbox,
              "#teacher-interface-work-history-school-form-start-date-is-estimate-1-field"

      element :still_employed_false_radio,
              "#teacher-interface-work-history-school-form-still-employed-false-field",
              visible: false

      element :end_date_month_input,
              "#teacher_interface_work_history_school_form_end_date_2i"
      element :end_date_year_input,
              "#teacher_interface_work_history_school_form_end_date_1i"
      element :end_date_is_input_checkbox,
              "#teacher-interface-work-history-school-form-end-date-is-estimate-1-field"

      element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      element :save_and_come_back_later_button,
              ".govuk-button.govuk-button--secondary"

      def check_meets_all_requirements
        meets_all_requirements_checkbox.click
      end

      def fill_in_school_name(text)
        school_name_input.fill_in(with: text)
      end

      def fill_in_address_line1(text)
        address_line1_input.fill_in(with: text)
      end

      def fill_in_address_line2(text)
        address_line2_input.fill_in(with: text)
      end

      def fill_in_city(text)
        city_input.fill_in(with: text)
      end

      def fill_in_country(text)
        country_input.fill_in(with: text)
      end

      def fill_in_postcode(text)
        postcode_input.fill_in(with: text)
      end

      def fill_in_school_website(text)
        school_website_input.fill_in(with: text)
      end

      def fill_in_job(text)
        job_input.fill_in(with: text)
      end

      def fill_in_hours_per_week(text)
        hours_per_week_input.fill_in(with: text)
      end

      def fill_in_start_date(month:, year:)
        start_date_month_input.fill_in(with: month)
        start_date_year_input.fill_in(with: year)
      end

      def select_not_still_employed
        still_employed_false_radio.choose
      end

      def fill_in_end_date(month:, year:)
        end_date_month_input.fill_in(with: month)
        end_date_year_input.fill_in(with: year)
      end

      def click_continue
        continue_button.click
      end
    end
  end
end
