module PageObjects
  module TeacherInterface
    class SignUp < SitePrism::Page
      set_url "/teacher/sign_up/"

      element :heading, "h1"
      element :email_heading, ".govuk-heading-xl"
      element :hint, "#teacher-email-hint"
      element :continue_button, ".govuk-button"
    end
  end
end
