# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class PrioritisationReferencesNew < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/prioritisation-reference-requests/new"

      section :form, "form" do
        element :submit_button, ".govuk-button"
      end
    end
  end
end
