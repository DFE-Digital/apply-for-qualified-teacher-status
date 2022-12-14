module PageObjects
  module TeacherInterface
    class ConfirmOtp < SitePrism::Page
      set_url "/teacher/otp/new{?uuid}"

      element :heading, "h1"

      section :form, "form" do
        element :otp_input, ".govuk-input"
        element :continue_button, ".govuk-button"
      end

      load_validation { has_heading? && has_form? }

      def submit(otp:)
        form.otp_input.fill_in with: otp
        form.continue_button.click
      end
    end
  end
end
