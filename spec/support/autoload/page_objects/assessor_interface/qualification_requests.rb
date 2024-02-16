# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class QualificationRequests < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/qualification-requests"

      section :task_list, TaskList, ".app-task-list"

      element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
    end
  end
end
