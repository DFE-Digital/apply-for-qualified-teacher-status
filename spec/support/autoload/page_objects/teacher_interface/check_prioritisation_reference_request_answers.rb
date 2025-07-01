# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class CheckPrioritisationReferenceRequestAnswers < SitePrism::Page
      set_url "/teacher/prioritisation-references/{slug}/edit"

      section :summary_list, GovukSummaryList, ".govuk-summary-list"
      element :submit_button, ".govuk-button"
    end
  end
end
