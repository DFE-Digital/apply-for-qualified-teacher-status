module PageObjects
  module TeacherInterface
    class Application < SitePrism::Page
      set_url "/teacher/application"

      element :heading, "h1"
      element :content_title, "app-task-list_section"
      element :app_task_list, ".app-task-list"

      element :check_answers, ".govuk-button:nth-of-type(1)"
      element :save_and_sign_out, ".govuk-button:nth-of-type(2)"

      section :task_list, TaskList, ".app-task-list"

      def personal_information_task_item
        task_list.find_item("Enter your personal information")
      end

      def qualifications_task_item
        task_list.find_item("Add your teaching qualifications")
      end

      def age_range_task_item
        task_list.find_item("Enter the age range you can teach")
      end

      def subjects_task_item
        task_list.find_item("Enter the subjects you can teach")
      end

      def english_language_task_item
        task_list.find_item("Verify your English language proficiency")
      end

      def work_history_task_item
        task_list.find_item("Add your work history")
      end

      def registration_number_task_item
        task_list.find_item("Enter your registration number")
      end

      def upload_written_statement_task_item
        task_list.find_item("Upload your written statement")
      end

      def provide_written_statement_task_item
        task_list.find_item("Provide your written statement")
      end
    end
  end
end
