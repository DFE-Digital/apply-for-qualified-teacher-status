# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class ProfessionalStandingRequestEdit < SitePrism::Page
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}/professional-standing-request" \
                "/request"

      section :form, "form" do
        element :yes_radio_item,
                "#assessor-interface-verify-requestable-form-passed-true-field",
                visible: false
        element :no_radio_item,
                "#assessor-interface-verify-requestable-form-passed-false-field",
                visible: false
        element :continue_button, "button"
      end
    end
  end
end
