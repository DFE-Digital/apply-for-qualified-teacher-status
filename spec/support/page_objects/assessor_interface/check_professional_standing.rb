module PageObjects
  module AssessorInterface
    class ProfessionalStandingCard < SitePrism::Section
      element :heading, "h2"
    end

    class CheckProfessionalStanding < SitePrism::Page
      set_url "/assessor/applications/{application_id}/check_professional_standing"

      element :heading, "h1"
      element :continue_button, ".govuk-button"
      sections :professional_standing_cards,
               ProfessionalStandingCard,
               ".govuk-summary-list__card"
    end
  end
end
