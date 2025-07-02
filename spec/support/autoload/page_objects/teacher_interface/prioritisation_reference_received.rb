# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class PrioritisationReferenceReceived < SitePrism::Page
      set_url "/teacher/prioritisation-references/{slug}"

      element :confirmation_panel, ".govuk-panel"
    end
  end
end
