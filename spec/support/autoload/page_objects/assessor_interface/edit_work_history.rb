# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class EditWorkHistory < SitePrism::Page
      set_url "/assessor/applications/{reference}/work-histories/{work_history_id}/edit"

      section :form, "form" do
        element :name_field,
                "#assessor-interface-work-history-contact-form-name-field"
        element :job_field,
                "#assessor-interface-work-history-contact-form-job-field"
        element :email_field,
                "#assessor-interface-work-history-contact-form-email-field"
        element :submit_button, ".govuk-button"
      end
    end
  end
end
