# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class EditWorkHistoryContact < SitePrism::Page
      set_url "/teacher/application/work_histories/{work_history_id}/contact"

      element :name_input,
              "#teacher-interface-work-history-contact-form-contact-name-field"
      element :job_input,
              "#teacher-interface-work-history-contact-form-contact-job-field"
      element :email_input,
              "#teacher-interface-work-history-contact-form-contact-email-field"
      element :email_input_with_error,
              "#teacher-interface-work-history-contact-form-contact-email-field-error"

      element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      element :save_and_come_back_later_button,
              ".govuk-button.govuk-button--secondary"

      def fill_in_name(text)
        name_input.fill_in(with: text)
      end

      def fill_in_job(text)
        job_input.fill_in(with: text)
      end

      def fill_in_email(text)
        email_input.fill_in(with: text)
      end

      def fill_in_email_with_error(text)
        email_input_with_error.fill_in(with: text)
      end

      def click_continue
        continue_button.click
      end
    end
  end
end
