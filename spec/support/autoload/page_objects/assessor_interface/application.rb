# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class Application < SitePrism::Page
      set_url "/assessor/applications/{reference}"

      element :back_link, "a", text: "Back"

      element :add_note_button, ".app-inline-action .govuk-button"

      section :summary_list, GovukSummaryList, ".govuk-summary-list"
      sections :task_lists, GovukTaskList, ".govuk-task-list"

      def name_summary
        summary_list.find_row(key: "Name")
      end

      def assessor_summary
        summary_list.find_row(key: "Assigned to")
      end

      def reviewer_summary
        summary_list.find_row(key: "Reviewer")
      end

      def status_summary
        summary_list.find_row(key: "Status")
      end

      def find_task_list_item(name)
        task_lists.map { |task_list| task_list.find_item(name) }.compact.first
      end

      def preliminary_check_task
        find_task_list_item("Preliminary check (qualifications)")
      end

      def awaiting_professional_standing_task
        find_task_list_item("Awaiting third-party professional standing")
      end

      def personal_information_task
        find_task_list_item("Check personal information")
      end

      def qualifications_task
        find_task_list_item("Check qualifications")
      end

      def age_range_subjects_task
        find_task_list_item("Verify age range and subjects")
      end

      def english_language_proficiency_task
        find_task_list_item("Check English language proficiency")
      end

      def work_history_task
        find_task_list_item("Check work history")
      end

      def professional_standing_task
        find_task_list_item("Check professional standing")
      end

      def review_first_requested_information_task
        find_task_list_item(
          "Review further information received - first request",
        )
      end

      def review_second_requested_information_task
        find_task_list_item(
          "Review further information received - second request",
        )
      end

      def review_final_requested_information_task
        find_task_list_item(
          "Review further information received - final request",
        )
      end

      def verify_professional_standing_task
        find_task_list_item("Verify LoPS")
      end

      def verify_qualifications_task
        find_task_list_item("Verify qualifications")
      end

      def verify_references_task
        find_task_list_item("Verify references")
      end

      def assessment_decision_task
        find_task_list_item("Assessment decision")
      end

      def review_verifications_task
        find_task_list_item("Review verifications")
      end

      def verification_decision_task
        find_task_list_item("Verification decision")
      end
    end
  end
end
