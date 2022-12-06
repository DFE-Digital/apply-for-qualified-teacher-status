module PageObjects
  module TeacherInterface
    class CheckEmail < SitePrism::Page
      set_url "/teacher/check_email?{?email}"

      element :heading, "h1"

      load_validation { has_heading? }
    end
  end
end
