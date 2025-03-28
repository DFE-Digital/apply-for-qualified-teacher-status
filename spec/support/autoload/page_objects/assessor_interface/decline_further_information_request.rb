# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class DeclineFurtherInformationRequest < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/further-information-requests/{id}/decline"

      element :heading, ".govuk-heading-xl"

      section :form, "form" do
        element :note_textarea, ".govuk-textarea"
        element :submit_button, ".govuk-button"
      end
    end
  end
end
