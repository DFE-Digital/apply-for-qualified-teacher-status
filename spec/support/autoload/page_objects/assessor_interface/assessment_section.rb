module PageObjects
  module AssessorInterface
    class AssessmentSection < SitePrism::Page
      element :heading, "h1"

      section :form, "form" do
        section :yes_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(1)"
        section :no_radio_item,
                PageObjects::GovukRadioItem,
                ".govuk-radios__item:nth-of-type(2)"
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
