module PageObjects
  module AssessorInterface
    class ProfessionalStandingCard < SitePrism::Section
      element :heading, "h2"
      element :registration_number,
              "dl.govuk-summary-list > div:nth-of-type(1) > dd:nth-of-type(1)"
    end

    class CheckProfessionalStanding < AssessmentSection
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}/sections/professional_standing"

      sections :cards, ProfessionalStandingCard, ".govuk-summary-card"

      section :induction_required_form, "form" do
        element :no_radio_item,
                "#assessor-interface-assessment-section-form-induction-required-false-field",
                visible: false
        element :yes_radio_item,
                "#assessor-interface-assessment-section-form-induction-required-true-field",
                visible: false
      end

      def proof_of_recognition
        cards&.first
      end
    end
  end
end
