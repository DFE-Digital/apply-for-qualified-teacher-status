module PageObjects
  module AssessorInterface
    class ProfessionalStandingCard < SitePrism::Section
      element :heading, "h2"
      element :registration_number,
              "dl.govuk-summary-list > div:nth-of-type(1) > dd:nth-of-type(1)"
    end

    class CheckProfessionalStanding < AssessmentSection
      set_url "/assessor/applications/{reference}/assessments/{assessment_id}/sections/{section_id}"

      sections :cards, ProfessionalStandingCard, ".govuk-summary-card"

      section :scotland_full_registration_form, "form" do
        element :true_radio_item,
                "#assessor-interface-assessment-section-form-scotland-full-registration-true-field",
                visible: false
        element :false_radio_item,
                "#assessor-interface-assessment-section-form-scotland-full-registration-false-field",
                visible: false
      end

      section :induction_required_form, "form" do
        element :false_radio_item,
                "#assessor-interface-assessment-section-form-induction-required-false-field",
                visible: false
        element :true_radio_item,
                "#assessor-interface-assessment-section-form-induction-required-true-field",
                visible: false
      end

      def proof_of_recognition
        cards&.first
      end
    end
  end
end
