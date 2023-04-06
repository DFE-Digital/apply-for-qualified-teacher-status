module PageObjects
  module TeacherInterface
    class CheckQualifications < SitePrism::Page
      set_url "/teacher/application/qualifications/check"

      element :heading, "h1"
      sections :summary_lists, GovukSummaryList, ".govuk-summary-list"
      element :continue_button, ".govuk-button"
    end
  end
end
