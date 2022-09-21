module PageObjects
  module TeacherInterface
    class CreateOrSignIn < SitePrism::Page
      set_url "/teacher/create_or_sign_in"

      element :heading, "h1"
      element :radio_heading, "govuk-fieldset__legend govuk-fieldset__legend--m"
      element :continue_button, ".govuk-button"
      element :radio_button, "govuk-radios__input"
      element :email_input, "govuk-input"
    end
  end
end
