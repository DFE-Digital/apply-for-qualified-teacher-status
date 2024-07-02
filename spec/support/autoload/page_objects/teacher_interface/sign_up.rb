# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class SignUp < SitePrism::Page
      set_url "/teacher/sign_up"

      element :heading, "h1"

      section :form, "form" do
        element :email_label, ".govuk-label"
        element :email_hint, ".govuk-hint"
        element :email_input, ".govuk-input"
        element :continue_button, ".govuk-button"
      end

      load_validation { has_heading? && has_form? }

      def submit(email:)
        form.email_input.fill_in with: email
        form.continue_button.click
      end
    end
  end
end
