# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class ConsentRequests < SitePrism::Page
      set_url "/teacher/application/consent-requests"

      sections :task_lists, GovukTaskList, ".govuk-task-list"

      element :check_your_answers_button,
              ".govuk-button:not(.govuk-button--secondary)"
      element :save_and_sign_out_button, ".govuk-button.govuk-button--secondary"
    end
  end
end
