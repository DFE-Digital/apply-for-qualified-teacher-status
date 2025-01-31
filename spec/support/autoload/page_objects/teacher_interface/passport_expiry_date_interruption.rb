# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class PassportExpiryDateInterruption < SitePrism::Page
      set_url "/teacher/application/passport_document/expired"

      element :heading, "h1"

      section :form, "form" do
        element :back_to_expiry_date_form_radio,
                "#back-to-expiry-date-true-field",
                visible: false
        element :back_to_application_task_list_radio,
                "#back-to-expiry-date-false-field",
                visible: false

        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
