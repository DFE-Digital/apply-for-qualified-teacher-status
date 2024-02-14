# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class QualificationRequestDownload < SitePrism::Page
      set_url "/teacher/application/qualification-requests/{id}/download"

      element :downloaded_checkbox, ".govuk-checkboxes__input", visible: false

      element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      element :save_and_sign_out_button, ".govuk-button.govuk-button--secondary"
    end
  end
end
