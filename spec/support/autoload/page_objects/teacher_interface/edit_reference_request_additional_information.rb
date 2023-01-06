# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class EditReferenceRequestAdditionalInformation < SitePrism::Page
      set_url "/teacher/references/{slug}/additional-information"

      section :form, "form" do
        element :additional_information_textarea, ".govuk-textarea"
        element :continue_button, ".govuk-button"
      end

      def submit(additional_information:)
        form.additional_information_textarea.fill_in with:
          additional_information
        form.continue_button.click
      end
    end
  end
end
