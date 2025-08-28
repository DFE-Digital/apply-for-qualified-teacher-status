# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class CheckFurtherInformationRequestAnswers < SitePrism::Page
      set_url "/teacher/application/further_information_requests/{request_id}/edit"

      element :heading, ".govuk-heading-xl"
      sections :summary_lists, GovukSummaryList, ".govuk-summary-list"
      element :submit_button, ".govuk-button"
    end
  end
end
