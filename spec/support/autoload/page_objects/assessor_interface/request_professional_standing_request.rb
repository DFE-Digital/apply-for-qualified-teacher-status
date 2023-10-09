# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class RequestProfessionalStandingRequest < SitePrism::Page
      set_url "/assessor/applications/{application_form_id}/assessments/{assessment_id}" \
                "/professional-standing-request/request"

      section :form, "form" do
        element :yes_radio_item,
                "#assessor-interface-requestable-request-form-passed-true-field",
                visible: false
        element :no_radio_item,
                "#assessor-interface-requestable-request-form-passed-false-field",
                visible: false
        element :continue_button, "button"
      end
    end
  end
end
