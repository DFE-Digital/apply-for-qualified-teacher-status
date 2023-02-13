# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class CheckPersonalInformation < SitePrism::Page
      set_url "/teacher/application/personal_information/check"

      element :heading, "h1"
      section :summary_list, GovukSummaryList, ".govuk-summary-list"
      element :continue_button, ".govuk-button"
    end
  end
end
