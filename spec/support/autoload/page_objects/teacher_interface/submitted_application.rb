# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class SubmittedApplication < SitePrism::Page
      set_url "/teacher/application"

      element :heading, ".govuk-heading-xl"
      section :panel, GovukPanel, ".govuk-panel"
    end
  end
end
