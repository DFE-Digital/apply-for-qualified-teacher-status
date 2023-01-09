# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class ReferenceReceived < SitePrism::Page
      set_url "/teacher/references/{slug}"

      element :confirmation_panel, ".govuk-panel"
    end
  end
end
