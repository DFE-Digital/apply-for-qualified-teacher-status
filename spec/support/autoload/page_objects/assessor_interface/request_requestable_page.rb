# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class RequestRequestablePage < SitePrism::Page
      section :form, "form" do
        element :passed_checkbox,
                "#assessor-interface-requestable-request-form-passed-true-field",
                visible: false
        element :submit_button, ".govuk-button"
      end

      def submit_checked
        form.passed_checkbox.click
        form.submit_button.click
      end

      def submit_unchecked
        form.submit_button.click
      end
    end
  end
end
