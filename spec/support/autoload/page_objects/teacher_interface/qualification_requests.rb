# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class QualificationRequests < SitePrism::Page
      set_url "/teacher/application/qualification-requests"

      element :check_your_answers_button,
              ".govuk-button:not(.govuk-button--secondary)"
      element :save_and_sign_out_button, ".govuk-button.govuk-button--secondary"
    end
  end
end
