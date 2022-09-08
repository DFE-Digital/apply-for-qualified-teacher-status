module PageObjects
  module AssessorInterface
    class QualificationCard < SitePrism::Section
      element :heading, "h2"
      element :title,
              "dl.govuk-summary-list > div:nth-of-type(1) > dd:nth-of-type(1)"
    end

    class CheckQualifications < SitePrism::Page
      set_url "/assessor/applications/{application_id}/check_qualifications"

      element :heading, "h1"
      element :continue_button, ".govuk-button"
      sections :qualification_cards,
               QualificationCard,
               ".govuk-summary-list__card"

      def teaching_qualification
        qualification_cards&.first
      end
    end
  end
end
