# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ReviewVerifications < SitePrism::Page
      set_url "/assessor/applications/{application_form_id}/assessments/{assessment_id}" \
                "/review-verifications"

      section :task_list, TaskList, ".app-task-list"

      element :back_to_overview_button, ".govuk-button"
    end
  end
end
