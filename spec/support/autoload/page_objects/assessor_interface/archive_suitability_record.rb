# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ArchiveSuitabilityRecord < SitePrism::Page
      set_url "/assessor/suitability-records/{id}/archive"

      section :form, "form" do
        element :note_field,
                "#assessor-interface-archive-suitability-record-form-note-field"
        element :submit_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
