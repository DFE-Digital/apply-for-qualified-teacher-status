# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ReactivateEligibilityDomain < SitePrism::Page
      set_url "/assessor/eligibility-domains/{id}/reactivate"

      section :form, "form" do
        element :note_field,
                "#assessor-interface-reactivate-eligibility-domain-form-note-field"
        element :submit_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
