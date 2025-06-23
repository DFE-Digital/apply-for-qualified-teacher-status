# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class CheckOtherEnglandWorkHistories < SitePrism::Page
      set_url "/teacher/application/other_england_work_histories/check"

      element :heading, "h1"
      sections :summary_cards, GovukSummaryCard, ".govuk-summary-card"
      element :continue_button, ".govuk-button"
    end
  end
end
