# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class QualificationRequestsUnsignedConsentDocument < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/qualification-requests/unsigned-consent-document"

      section :form, "form" do
        element :generated_checkbox, ".govuk-checkboxes__input", visible: false
        element :continue_button, ".govuk-button:not(.govuk-button--inverse)"
      end

      def submit_generated
        form.generated_checkbox.check
        form.continue_button.click
      end
    end
  end
end
