# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class EditEligibilityDomain < SitePrism::Page
      set_url "/assessor/eligibility-domains/{id}/edit"

      element :heading, "h1"

      section :form, "form" do
        element :note_field, "#assessor-interface-create-note-form-text-field"
        element :submit_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
