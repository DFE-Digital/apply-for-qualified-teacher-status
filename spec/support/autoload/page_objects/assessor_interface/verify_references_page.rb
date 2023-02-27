# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class VerifyReferencesPage < SitePrism::Page
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}/verify-references"

      section :task_list, ".app-task-list__item" do
        elements :reference_requests, ".app-task-list__task-name a"
        elements :status_tags, ".app-task-list__tag"
      end

      section :form, "form" do
        element :yes_radio_item,
                "#assessor-interface-verify-references-form-references-verified-true-field",
                visible: false
        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
