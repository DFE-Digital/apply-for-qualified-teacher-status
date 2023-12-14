# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ReferenceRequests < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/reference-requests"

      section :task_list, TaskList, ".app-task-list"

      section :form, "form" do
        element :yes_radio_item,
                "#assessor-interface-verify-references-form-references-verified-true-field",
                visible: false
        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
