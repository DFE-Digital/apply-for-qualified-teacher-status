# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class Application < SitePrism::Page
      set_url "/teacher/application"

      element :heading, "h1"
      element :content_title, "app-task-list_section"
      element :app_task_list, ".app-task-list"

      element :check_answers, ".govuk-button:not(.govuk-button--secondary)"
      element :save_and_sign_out, ".govuk-button.govuk-button--secondary"
      element :start_now_button, ".govuk-button:not(.govuk-button--secondary)"

      sections :task_lists, GovukTaskList, ".govuk-task-list"

      def find_task_list_item(name)
        task_lists.map { |task_list| task_list.find_item(name) }.compact.first
      end

      def personal_information_task_item
        find_task_list_item("Enter your personal information")
      end

      def passport_document_task_item
        find_task_list_item("Upload your passport")
      end

      def qualifications_task_item
        find_task_list_item("Add your teaching qualifications")
      end

      def age_range_task_item
        find_task_list_item("Enter the age range you can teach")
      end

      def subjects_task_item
        find_task_list_item("Enter the subjects you can teach")
      end

      def english_language_task_item
        find_task_list_item("Verify your English language proficiency")
      end

      def work_history_task_item
        find_task_list_item("Add your work history")
      end

      def registration_number_task_item
        find_task_list_item("Enter your registration number")
      end

      def ghana_registration_number_task_item
        find_task_list_item("Enter your teacher license number")
      end

      def upload_written_statement_task_item
        find_task_list_item("Upload your written statement")
      end

      def provide_written_statement_task_item
        find_task_list_item("Provide your written statement")
      end
    end
  end
end
