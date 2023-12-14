# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ReferenceRequests < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/reference-requests"

      section :task_list, GovukTaskList, ".govuk-task-list"

      element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
    end
  end
end
