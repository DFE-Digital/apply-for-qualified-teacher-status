# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class EditQualificationRequestLocation < SitePrism::Page
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}" \
                "/qualification-requests-location/{id}/edit"

      section :form, "form" do
        element :received_checkbox, ".govuk-checkboxes__input", visible: false
        element :note_textarea, ".govuk-textarea"
        element :submit_button, ".govuk-button"
      end
    end
  end
end
