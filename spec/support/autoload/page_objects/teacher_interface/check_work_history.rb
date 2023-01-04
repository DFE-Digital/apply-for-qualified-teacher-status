module PageObjects
  module TeacherInterface
    class CheckWorkHistory < SitePrism::Page
      set_url "/teacher/application{/new_regs}/work_histories/{work_history_id}/check"

      element :heading, "h1"
      section :summary_list, GovukSummaryList, ".govuk-summary-list"
      element :continue_button, ".govuk-button"
    end
  end
end
