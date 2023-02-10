module PageObjects
  module TeacherInterface
    class CheckWorkHistories < SitePrism::Page
      set_url "/teacher/application/work_histories/check"

      element :heading, "h1"
      sections :summary_list_cards, GovukSummaryListCard, ".govuk-summary-card"
      element :continue_button, ".govuk-button"
    end
  end
end
