module PageObjects
  module AssessorInterface
    class AssessmentSection < SitePrism::Page
      element :heading, "h1"

      section :form, "form" do
        element :yes_radio_item,
                "#assessor-interface-assessment-section-form-passed-true-field",
                visible: false
        element :no_radio_item,
                "#assessor-interface-assessment-section-form-passed-field",
                visible: false
        sections :failure_reason_checkbox_items,
                 PageObjects::GovukCheckboxItem,
                 ".govuk-checkboxes__item"
        elements :failure_reason_note_textareas,
                 ".govuk-checkboxes__conditional .govuk-textarea"
        element :continue_button, "button"
      end
    end
  end
end
