# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class QualificationRequestLocations < SitePrism::Page
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}" \
                "/qualification-requests/locations"

      section :task_list, ".app-task-list__item" do
        elements :qualification_requests, ".app-task-list__task-name a"
        elements :status_tags, ".app-task-list__tag"
      end

      element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
    end
  end
end
