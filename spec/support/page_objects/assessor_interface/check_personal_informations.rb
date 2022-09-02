module PageObjects
  module AssessorInterface
    class CheckPersonalInformationCard < SitePrism::Section
      element :heading, "h2"
    end

    class CheckPersonalInformation < SitePrism::Page
      set_url "/assessor/applications/{application_id}/check_personal_information"

      element :heading, "h1"
      element :continue_button, ".govuk-button"
      sections :personal_informations_cards,
               CheckPersonalInformationCard,
               ".govuk-summary-list__card"
    end
  end
end
