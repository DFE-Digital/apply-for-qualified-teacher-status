module PageObjects
  module AssessorInterface
    class Application < SitePrism::Page
      set_url "/assessor/applications/{application_id}"

      element :back_link, "a", text: "Back"

      element :add_note_button, ".app-inline-action .govuk-button"

      section :overview, "#app-application-overview" do
        element :name, "div:nth-of-type(1) > dd:nth-of-type(1)"
        element :assessor_name, "div:nth-of-type(7) > dd:nth-of-type(1)"
        element :reviewer_name, "div:nth-of-type(8) > dd:nth-of-type(1)"
        element :status, "div:nth-of-type(10) > dd:nth-of-type(1)"
      end

      section :task_list, TaskList, ".app-task-list"

      section :management_tasks, ".app-task-list + .govuk-warning-text" do
        elements :links, ".govuk-link"
      end

      def preliminary_check_task
        task_list.find_item("Preliminary check (qualifications)")
      end

      def awaiting_professional_standing_task
        task_list.find_item("Awaiting third-party professional standing")
      end

      def personal_information_task
        task_list.find_item("Check personal information")
      end

      def qualifications_task
        task_list.find_item("Check qualifications")
      end

      def age_range_subjects_task
        task_list.find_item("Verify age range and subjects")
      end

      def english_language_proficiency_task
        task_list.find_item("Check English language proficiency")
      end

      def work_history_task
        task_list.find_item("Check work history")
      end

      def professional_standing_task
        task_list.find_item("Check professional standing")
      end

      def review_requested_information_task
        task_list.find_item("Review requested information from applicant")
      end

      def record_qualification_requests_task
        task_list.find_item("Record qualifications responses")
      end

      def review_qualification_requests_task
        task_list.find_item("Review qualifications responses")
      end

      def assessment_recommendation_task
        task_list.find_item("Assessment recommendation")
      end

      def verify_references_task
        task_list.find_item("Verify reference requests")
      end

      def record_professional_standing_request_task
        task_list.find_item("Record LOPS response")
      end

      def review_professional_standing_request_task
        task_list.find_item("Review LOPS response")
      end
    end
  end
end
