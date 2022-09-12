module PageObjects
  module AssessorInterface
    class ProfessionalStandingCard < SitePrism::Section
      element :heading, "h2"
      element :reference_number,
              "dl.govuk-summary-list > div:nth-of-type(1) > dd:nth-of-type(1)"
    end

    class CheckProfessionalStanding < AssessmentSection
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}/sections/professional_standing"

      sections :cards, ProfessionalStandingCard, ".govuk-summary-list__card"

      def proof_of_recognition
        cards&.first
      end
    end
  end
end
