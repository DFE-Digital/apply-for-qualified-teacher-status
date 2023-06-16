module PageObjects
  module AssessorInterface
    class WorkHistoryCard < SitePrism::Section
      element :heading, "h2"
      element :school_name,
              "dl.govuk-summary-list > div:nth-of-type(1) > dd:nth-of-type(1)"
    end

    class CheckWorkHistory < AssessmentSection
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}/sections/{section_id}"

      sections :cards, WorkHistoryCard, ".govuk-summary-card"

      def most_recent_role
        cards&.second
      end
    end
  end
end
