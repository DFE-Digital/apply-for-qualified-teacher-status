module PageObjects
  module AssessorInterface
    class EnglishLanguageProficiencyCard < SitePrism::Section
      element :heading, "h2"
    end

    class CheckEnglishLanguageProficiency < AssessmentSection
      set_url "/assessor/applications/{application_id}/assessments/ \
        {assessment_id}/sections/english_language_proficiency"

      sections :cards,
               EnglishLanguageProficiencyCard,
               ".govuk-summary-list__card"

      elements :lists, ".govuk-list"

      element :exemption_heading, "h2.govuk-heading-m"
      element :return_button, ".govuk-button", text: "Return to task list"

      def personal_information
        cards&.first
      end
    end
  end
end
