# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class UploadConsentDocument < SitePrism::Page
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}" \
                "/consent-requests/{id}/upload"

      section :form, "form" do
        element :original_attachment,
                "#assessor-interface-upload-unsigned-consent-document-form-original-attachment-field"

        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      end

      def submit(file:)
        form.original_attachment.attach_file file
        form.continue_button.click
      end
    end
  end
end
