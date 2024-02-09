# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class CheckQualificationRequests < SitePrism::Page
      set_url "/teacher/application/qualification-requests/check"

      element :heading, "h1"
      section :summary_card, GovukSummaryCard, ".govuk-summary-card"
      element :submit_button, ".govuk-button"
    end
  end
end
