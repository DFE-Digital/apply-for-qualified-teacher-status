# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class CheckWorkHistories < SitePrism::Page
      set_url "/teacher/application/work_histories/check"

      element :heading, "h1"
      sections :summary_cards, GovukSummaryCard, ".govuk-summary-card"
      element :continue_button, ".govuk-button"

      def click_delete_first_work_history
        summary_cards.first.actions.link.click
      end
    end
  end
end
