# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class LocateProfessionalStandingRequest < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/professional-standing-request/locate"

      section :form, "form" do
        element :received_checkbox, ".govuk-checkboxes__input", visible: false
        element :received_yes_radio_item,
                "#assessor-interface-professional-standing-request-location-form-received-true-field",
                visible: false
        element :note_textarea, ".govuk-textarea"
        element :submit_button, ".govuk-button"
      end
    end
  end
end
