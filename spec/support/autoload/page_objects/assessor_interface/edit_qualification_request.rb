# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class EditQualificationRequest < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/qualification-requests/{id}/edit"

      section :form, "form" do
        element :received_true_radio_item,
                "#assessor-interface-qualification-request-form-received-true-field",
                visible: false
        element :received_false_radio_item,
                "#assessor-interface-qualification-request-form-received-false-field",
                visible: false

        element :passed_true_radio_item,
                "#assessor-interface-qualification-request-form-passed-true-field",
                visible: false
        element :passed_false_radio_item,
                "#assessor-interface-qualification-request-form-passed-false-field",
                visible: false

        element :note_field,
                "#assessor-interface-qualification-request-form-note-field"

        element :failed_true_radio_item,
                "#assessor-interface-qualification-request-form-failed-true-field",
                visible: false
        element :failed_false_radio_item,
                "#assessor-interface-qualification-request-form-failed-false-field",
                visible: false

        element :submit_button, ".govuk-button"
      end
    end
  end
end
