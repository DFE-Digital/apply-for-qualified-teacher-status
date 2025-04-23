# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ConfirmFollowUpFurtherInformationRequest < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/further-information-requests/{id}/confirm-follow-up"

      element :heading, ".govuk-heading-xl"

      section :form, "form" do
        element :submit_button, ".govuk-button"
      end
    end
  end
end
