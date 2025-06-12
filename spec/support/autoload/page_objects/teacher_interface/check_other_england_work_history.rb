# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class CheckOtherEnglandWorkHistory < SitePrism::Page
      set_url "/teacher/application/other_england_work_histories/{work_history_id}/check"

      element :heading, "h1"
      section :summary_list, GovukSummaryList, ".govuk-summary-list"
      element :continue_button, ".govuk-button"
    end
  end
end
