# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class DeclinedApplication < SitePrism::Page
      set_url "/teacher/application"

      element :heading, "h1"
      element :apply_check_eligibility_again_button, ".govuk-button"

      load_validation do
        has_heading? && has_apply_check_eligibility_again_button?
      end
    end
  end
end
