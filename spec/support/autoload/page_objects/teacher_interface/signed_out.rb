# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class SignedOut < SitePrism::Page
      set_url "/teacher/signed_out"

      element :heading, "h1"

      load_validation { has_heading? }
    end
  end
end
