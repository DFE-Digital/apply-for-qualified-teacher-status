module PageObjects
  module TeacherInterface
    class SignedOut < SitePrism::Page
      set_url "/teacher/signed_out"

      element :body_content, ".govuk-main-wrapper"
    end
  end
end
