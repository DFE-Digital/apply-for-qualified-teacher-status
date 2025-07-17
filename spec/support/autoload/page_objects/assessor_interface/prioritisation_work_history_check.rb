# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class PrioritisationWorkHistoryCheck < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/prioritisation-work-history-checks/{prioritisation_work_history_check_id}/edit"

      section :form, "form" do
        element :true_radio_item,
                "#assessor-interface-prioritisation-work-history-check-form-passed-true-field",
                visible: false
        element :false_radio_item,
                "#assessor-interface-prioritisation-work-history-check-form-passed-field",
                visible: false
        sections :failure_reason_checkbox_items,
                 PageObjects::GovukCheckboxItem,
                 ".govuk-checkboxes__item"
        elements :failure_reason_note_textareas,
                 ".govuk-checkboxes__conditional .govuk-textarea"
        element :continue_button, ".govuk-button"
      end

      def submit_yes
        form.true_radio_item.choose
        form.continue_button.click
      end

      def submit_no
        form.false_radio_item.choose
        form.continue_button.click
      end
    end
  end
end
