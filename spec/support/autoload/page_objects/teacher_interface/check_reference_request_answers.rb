# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class CheckReferenceRequestAnswers < SitePrism::Page
      set_url "/teacher/references/{slug}/edit"

      section :summary_list, GovukSummaryList, ".govuk-summary-list"
    end
  end
end
