# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class PrioritisationDecision < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/edit-prioritisation"

      section :form, "form" do
        element :true_radio_item,
                "#assessor-interface-assessment-prioritisation-decision-form-passed-true-field",
                visible: false
        element :false_radio_item,
                "#assessor-interface-assessment-prioritisation-decision-form-passed-false-field",
                visible: false
        element :submit_button, ".govuk-button"
      end

      def submit_yes
        form.true_radio_item.choose
        form.submit_button.click
      end

      def submit_no
        form.false_radio_item.choose
        form.submit_button.click
      end
    end
  end
end
