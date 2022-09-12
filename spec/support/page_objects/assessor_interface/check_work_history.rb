module PageObjects
  module AssessorInterface
    class WorkHistoryCard < SitePrism::Section
      element :heading, "h2"
      element :school_name,
              "dl.govuk-summary-list > div:nth-of-type(1) > dd:nth-of-type(1)"
    end

    class CheckWorkHistory < SitePrism::Page
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}/sections/work_history"

      element :heading, "h1"
      element :continue_button, ".govuk-button"
      sections :work_history_cards, WorkHistoryCard, ".govuk-summary-list__card"

      def most_recent_role
        work_history_cards&.second
      end
    end
  end
end
