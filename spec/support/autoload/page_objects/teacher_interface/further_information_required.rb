# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class FurtherInformationRequired < SitePrism::Page
      set_url "/teacher/application/further_information_requests/{request_id}/items/{item_id}/edit"

      element :back_link, ".govuk-back-link"
      element :heading, ".govuk-heading-l"
      element :feedback, ".govuk-inset-text"

      section :form, "form" do
        element :response_textarea, ".govuk-textarea"
        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
        element :save_and_come_back_later_button,
                ".govuk-button.govuk-button--secondary"
        element :contact_name,
                "#teacher-interface-further-information-request-item-work-history-contact-form-contact-name-field"
        element :contact_job,
                "#teacher-interface-further-information-request-item-work-history-contact-form-contact-job-field"
        element :contact_email,
                "#teacher-interface-further-information-request-item-work-history-contact-form-contact-email-field"
      end
    end
  end
end
