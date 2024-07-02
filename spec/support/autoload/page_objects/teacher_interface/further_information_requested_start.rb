# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class FurtherInformationRequestedStart < SitePrism::Page
      set_url "/teacher/application"

      element :heading, ".govuk-heading-xl"
      element :status_tag, ".govuk-tag"
      element :start_button, ".govuk-button"
    end
  end
end
