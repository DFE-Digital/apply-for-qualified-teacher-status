# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class ReferenceRequested < SitePrism::Page
      set_url "/teacher/references/{slug}"

      element :work_history_details, ".govuk-inset-text p"
    end
  end
end
