module PageObjects
  module TeacherInterface
    class NewApplicationForm < SitePrism::Page
      set_url "/teacher/sign_up"

      element :heading, ".govuk-label"
      element :email_field, "govuk-input"
      element :continue_button, ".govuk-button"
    end
  end
end
