# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class EditWorkHistoryContact < SitePrism::Page
      set_url "/teacher/application/work_histories/{work_history_id}/contact"

      section :form, "form" do
        element :name_input,
                "#teacher-interface-work-history-contact-form-contact-name-field"
        element :job_input,
                "#teacher-interface-work-history-contact-form-contact-job-field"
        element :email_input,
                "#teacher-interface-work-history-contact-form-contact-email-field"

        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
        element :save_and_come_back_later_button,
                ".govuk-button.govuk-button--secondary"
      end
    end
  end
end
