module PageObjects
  module AssessorInterface
    class WorkHistoryCard < SitePrism::Section
      element :heading, "h2"
    end

    class CheckWorkHistory < SitePrism::Page
      set_url "/assessor/applications/{application_id}/check_work_history"

      element :heading, "h1"
      element :continue_button, ".govuk-button"
      sections :work_history_cards, WorkHistoryCard, ".govuk-summary-list__card"
    end
  end
end
