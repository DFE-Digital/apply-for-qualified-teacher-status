# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class MagicLink < SitePrism::Page
      set_url "/teacher/magic_link"

      element :heading, "h1"

      section :form, "form" do
        element :continue_button, ".govuk-button"
      end

      load_validation { has_heading? && has_form? }

      def sign_in
        form.continue_button.click
      end
    end
  end
end
