# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ResendEmailReferenceRequest < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/reference-requests/{id}/resend-email"

      section :form, "form" do
        element :submit_button, ".govuk-button"
      end
    end
  end
end
