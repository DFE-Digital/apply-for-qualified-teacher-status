# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ReviewVerifications < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}/review"

      section :task_list, GovukTaskList, ".govuk-task-list"

      element :back_to_overview_button, ".govuk-button"
    end
  end
end
