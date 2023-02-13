# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class AgeRange < SitePrism::Page
      set_url "/teacher/application/age_range"

      element :heading, "h1"

      section :form, "form" do
        element :minimum_field,
                "#teacher-interface-age-range-form-minimum-field"
        element :maximum_field,
                "#teacher-interface-age-range-form-maximum-field"

        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
