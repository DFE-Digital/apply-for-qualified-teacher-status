module PageObjects
  module TeacherInterface
    class RetryOtp < SitePrism::Page
      set_url "/teacher/otp/retry{/error}"

      element :heading, "h1"

      load_validation { has_heading? }
    end
  end
end
