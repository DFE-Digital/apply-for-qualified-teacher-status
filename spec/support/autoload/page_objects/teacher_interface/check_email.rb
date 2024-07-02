# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class CheckEmail < SitePrism::Page
      set_url "/teacher/check_email{?email}"
    end
  end
end
