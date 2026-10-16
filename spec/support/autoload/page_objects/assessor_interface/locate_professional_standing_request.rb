# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class LocateProfessionalStandingRequest < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/professional-standing-request/locate"

      section :form, "form" do
        element :uploaded_file_summary, ".govuk-summary-list"
        element :replace_uploaded_file_heading,
                "h2",
                text: "Replace the uploaded file"
        element :replace_uploaded_file_instructions,
                "p",
                text:
                  "Upload a new file to replace the one you have already uploaded."

        element :attachment,
                "#assessor-interface-professional-standing-request-location-form-attachment-field"
        element :received_checkbox, ".govuk-checkboxes__input", visible: false
        element :received_true_radio_item,
                "#assessor-interface-professional-standing-request-location-form-received-true-field",
                visible: false
        element :note_textarea, ".govuk-textarea"
        element :submit_button, ".govuk-button"
      end
    end
  end
end
