# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class CheckPassportDocument < SitePrism::Page
      set_url "/teacher/application/passport_document/check"

      element :heading, "h1"
      section :summary_list, GovukSummaryList, ".govuk-summary-list"
      element :continue_button, ".govuk-button"
    end
  end
end
