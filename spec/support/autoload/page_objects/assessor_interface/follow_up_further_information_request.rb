# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class FollowUpFurtherInformationRequest < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/further-information-requests/{id}/follow-up"

      element :heading, ".govuk-heading-xl"

      section :form, "form" do
        elements :review_decision_note_textareas, ".govuk-textarea"
        element :submit_button, ".govuk-button"
      end
    end
  end
end
