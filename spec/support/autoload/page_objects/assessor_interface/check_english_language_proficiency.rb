module PageObjects
  module AssessorInterface
    class EnglishLanguageProficiencyCard < SitePrism::Section
      element :heading, "h2"
    end

    class CheckEnglishLanguageProficiency < AssessmentSection
      set_url "/assessor/applications/{application_form_id}/assessments/{assessment_id}/sections/{section_id}"

      sections :cards, EnglishLanguageProficiencyCard, ".govuk-summary-card"

      elements :lists, ".govuk-list"

      elements :h2s, "h2.govuk-heading-m"
      element :return_button, ".govuk-button", text: "Return to task list"

      def personal_information
        cards&.first
      end
    end
  end
end
