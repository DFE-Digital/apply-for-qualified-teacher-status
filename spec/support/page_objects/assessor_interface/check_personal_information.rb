module PageObjects
  module AssessorInterface
    class CheckPersonalInformationCard < SitePrism::Section
      element :heading, "h2"
      element :given_names,
              "dl.govuk-summary-list > div:nth-of-type(1) > dd:nth-of-type(1)"
      element :family_name,
              "dl.govuk-summary-list > div:nth-of-type(2) > dd:nth-of-type(1)"
    end

    class CheckPersonalInformation < SitePrism::Page
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}/sections/personal_information"

      element :heading, "h1"
      element :continue_button, ".govuk-button"
      sections :personal_information_cards,
               CheckPersonalInformationCard,
               ".govuk-summary-list__card"

      def personal_information
        personal_information_cards&.first
      end
    end
  end
end
