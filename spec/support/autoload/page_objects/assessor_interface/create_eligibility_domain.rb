# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class CreateEligibilityDomain < SitePrism::Page
      set_url "/assessor/eligibility-domains/new"

      element :heading, "h1"

      section :form, "form" do
        element :domain_field,
                "#assessor-interface-create-eligibility-domain-form-domain-field"
        element :note_field,
                "#assessor-interface-create-eligibility-domain-form-note-field"
        element :submit_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
