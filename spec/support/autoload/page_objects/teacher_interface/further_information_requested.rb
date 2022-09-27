module PageObjects
  module TeacherInterface
    class FurtherInformationRequested < SitePrism::Page
      set_url "/teacher/application/further_information_requests/{request_id}"

      element :heading, ".govuk-heading-l"
      section :task_list, TaskList, ".app-task-list"
      element :save_and_sign_out_button, ".govuk-button"
    end
  end
end
