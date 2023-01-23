# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class EditProfessionalStandingRequest < SitePrism::Page
      set_url "/assessor/applications/{application_id}/professional-standing-request/edit"

      section :form, "form" do
        element :received_checkbox, ".govuk-checkboxes__input", visible: false
        element :note_textarea, ".govuk-textarea"
        element :continue_button, ".govuk-button"
      end
    end
  end
end
