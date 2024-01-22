# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class VerifyProfessionalStandingRequest < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/professional-standing-request/verify"

      section :form, "form" do
        element :passed_true_radio_item,
                "#assessor-interface-requestable-verify-passed-form-passed-true-field",
                visible: false
        element :passed_false_radio_item,
                "#assessor-interface-requestable-verify-passed-form-passed-false-field",
                visible: false
        element :received_true_radio_item,
                "#assessor-interface-requestable-verify-passed-form-received-true-field",
                visible: false
        element :received_false_radio_item,
                "#assessor-interface-requestable-verify-passed-form-received-false-field",
                visible: false
        element :submit_button, ".govuk-button"
      end

      def submit_yes
        form.passed_true_radio_item.choose
        form.submit_button.click
      end

      def submit_no(received: nil)
        form.passed_false_radio_item.choose

        if received
          form.received_true_radio_item.choose
        elsif received == false
          form.received_false_radio_item.choose
        end

        form.submit_button.click
      end
    end
  end
end
