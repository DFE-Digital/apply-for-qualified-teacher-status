# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class FurtherInformationRequested < SitePrism::Page
      set_url "/teacher/application/further_information_requests/{request_id}"

      element :heading, ".govuk-heading-l"
      section :task_list, GovukTaskList, ".govuk-task-list"

      element :check_your_answers_button,
              ".govuk-button:not(.govuk-button--secondary)"
      element :save_and_sign_out_button, ".govuk-button.govuk-button--secondary"
    end
  end
end
