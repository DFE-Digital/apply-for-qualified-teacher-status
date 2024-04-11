# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class Login < SitePrism::Page
      set_url "/staff/sign_in"

      section :form, "form" do
        element :email_field, "#staff-email-field"
        element :password_field, "#staff-password-field"
        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      end

      element :azure_sign_in, "#button-sign-in-with-active-directory"

      def submit(email:, password:)
        form.email_field.fill_in with: email
        form.password_field.fill_in with: password
        form.continue_button.click
      end
    end
  end
end
