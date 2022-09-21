module PageObjects
  module TeacherInterface
    class CheckYourEmail < SitePrism::Page
      set_url "/teacher/check_email?{?email}"

      element :heading, "h1"
      element :email_heading, "gov-uk-heading-xl"
      element :email_field, "govuk-input"
      element :continue_button, ".govuk-button"
    end
  end
end
