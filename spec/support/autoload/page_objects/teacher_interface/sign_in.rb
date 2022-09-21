module PageObjects
  module TeacherInterface
    class SignIn < SitePrism::Page
      set_url "/teacher/sign_in"

      element :heading, "h1"

      section :form, "form" do
        element :email_input, "input"
        element :submit_button, "button"
      end
    end
  end
end
