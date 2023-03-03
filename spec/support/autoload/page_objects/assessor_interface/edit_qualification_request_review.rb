# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class EditQualificationRequestReview < SitePrism::Page
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}" \
                "/qualification-requests/{id}/review"

      section :form, "form" do
        element :reviewed_yes_radio_item,
                "#assessor-interface-requestable-review-form-reviewed-true-field",
                visible: false
        element :reviewed_no_radio_item,
                "#assessor-interface-requestable-review-form-reviewed-false-field",
                visible: false

        element :passed_yes_radio_item,
                "#assessor-interface-requestable-review-form-passed-true-field",
                visible: false
        element :passed_no_radio_item,
                "#assessor-interface-requestable-review-form-passed-false-field",
                visible: false

        element :submit_button, ".govuk-button"
      end
    end
  end
end
