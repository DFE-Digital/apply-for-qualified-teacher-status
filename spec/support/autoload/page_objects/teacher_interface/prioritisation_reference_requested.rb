# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class PrioritisationReferenceRequested < SitePrism::Page
      set_url "/teacher/prioritisation-references/{slug}"

      element :work_history_details, ".govuk-inset-text p"
      element :start_button, ".govuk-button"
    end
  end
end
