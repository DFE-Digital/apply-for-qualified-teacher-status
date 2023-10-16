module PageObjects
  module AssessorInterface
    class PersonalInformationCard < SitePrism::Section
      element :heading, "h2"
      element :given_names,
              "dl.govuk-summary-list > div:nth-of-type(1) > dd:nth-of-type(1)"
      element :family_name,
              "dl.govuk-summary-list > div:nth-of-type(2) > dd:nth-of-type(1)"
    end

    class CheckPersonalInformation < AssessmentSection
      set_url "/assessor/applications/{application_form_id}/assessments/{assessment_id}/sections/{section_id}"

      sections :cards, PersonalInformationCard, ".govuk-summary-card"

      section :exemption_form, "form" do
        element :english_language_exempt,
                "#assessor-interface-assessment-section-form-english-language-section-passed-true-field",
                visible: false
      end

      def personal_information
        cards&.first
      end
    end
  end
end
