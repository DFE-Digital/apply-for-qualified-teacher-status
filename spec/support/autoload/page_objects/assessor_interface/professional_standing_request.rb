# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ProfessionalStandingRequest < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/professional-standing-request"

      section :task_list, GovukTaskList, ".govuk-task-list"
      element :status_tag, ".govuk-tag"

      def request_lops_verification_task
        task_list.find_item("Request LoPS verification")
      end

      def record_lops_response_task
        task_list.find_item("Record LoPS response")
      end
    end
  end
end
