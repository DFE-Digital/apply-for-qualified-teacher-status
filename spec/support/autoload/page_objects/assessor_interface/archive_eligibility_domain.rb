# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ArchiveEligibilityDomain < SitePrism::Page
      set_url "/assessor/eligibility-domains/{id}/archive"

      section :form, "form" do
        element :note_field,
                "#assessor-interface-archive-eligibility-domain-form-note-field"
        element :submit_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
