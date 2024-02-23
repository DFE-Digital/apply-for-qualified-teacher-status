# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class CheckConsentRequests < SitePrism::Page
      set_url "/teacher/application/consent-requests/check"

      element :heading, "h1"
      section :summary_card, GovukSummaryCard, ".govuk-summary-card"
      element :submit_button, ".govuk-button"
    end
  end
end
