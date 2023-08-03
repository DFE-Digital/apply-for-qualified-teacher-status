# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class DocumentAvailable < SitePrism::Page
      set_url "/teacher/application/documents/{application_id}/edit"

      element :heading, "h1"

      section :form, "form" do
        element :yes_radio_item,
                "#teacher-interface-document-available-form-available-true-field",
                visible: false
        element :no_radio_item,
                "#teacher-interface-document-available-form-available-false-field",
                visible: false
        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
