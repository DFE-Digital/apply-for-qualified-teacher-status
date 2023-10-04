# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class EditQualificationRequest < SitePrism::Page
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}" \
                "/qualification-requests/{id}/edit"

      section :form, "form" do
        element :received_yes_radio_item,
                "#assessor-interface-qualification-request-form-received-true-field",
                visible: false
        element :received_no_radio_item,
                "#assessor-interface-qualification-request-form-received-false-field",
                visible: false

        element :passed_yes_radio_item,
                "#assessor-interface-qualification-request-form-passed-true-field",
                visible: false
        element :passed_no_radio_item,
                "#assessor-interface-qualification-request-form-passed-false-field",
                visible: false

        element :note_field,
                "#assessor-interface-qualification-request-form-note-field"

        element :failed_yes_radio_item,
                "#assessor-interface-qualification-request-form-failed-true-field",
                visible: false
        element :failed_no_radio_item,
                "#assessor-interface-qualification-request-form-failed-false-field",
                visible: false

        element :submit_button, ".govuk-button"
      end
    end
  end
end
