# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class VerifyFailedRequestablePage < SitePrism::Page
      section :form, "form" do
        element :note_textarea, ".govuk-textarea"
        element :submit_button, ".govuk-button"
      end

      def submit(note:)
        form.note_textarea.fill_in with: note
        form.submit_button.click
      end
    end
  end
end
