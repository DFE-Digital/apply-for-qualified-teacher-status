# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class RequestProfessionalStandingRequest < SitePrism::Page
      set_url "/assessor/applications/{application_form_id}/assessments/{assessment_id}" \
                "/professional-standing-request/request"

      section :form, "form" do
        element :passed_checkbox,
                "#assessor-interface-requestable-request-form-passed-true-field",
                visible: false
        element :continue_button, "button"
      end
    end
  end
end
