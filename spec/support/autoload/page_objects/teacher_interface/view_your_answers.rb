# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class ViewYourAnswers < SitePrism::Page
      set_url "/teacher/application/answers"

      element :heading, "h1", match: :first

      section :about_you, "#app-application-form-about-you" do
        section :personal_information_summary_list,
                GovukSummaryList,
                "#app-check-your-answers-summary-personal-information"
        section :identification_document_summary_list,
                GovukSummaryList,
                "#app-check-your-answers-summary-identity-document"
        section :passport_document_summary_list,
                GovukSummaryList,
                "#app-check-your-answers-summary-passport-document"
      end

      section :who_you_can_teach, "#app-application-form-who-you-can-teach" do
        sections :qualification_summary_lists,
                 GovukSummaryList,
                 ".govuk-summary-card" \
                   ":not(#app-check-your-answers-summary-age-range)" \
                   ":not(#app-check-your-answers-summary-subjects)",
                 match: :first
        section :age_range_summary_list,
                GovukSummaryList,
                "#app-check-your-answers-summary-age-range"
        section :subjects_summary_list,
                GovukSummaryList,
                "#app-check-your-answers-summary-subjects"
      end

      section :your_english_language_proficiency,
              "#app-application-form-your-english-language-proficiency" do
        section :english_language_proficiency_summary_list,
                GovukSummaryList,
                "#app-check-your-answers-summary-english-language"
      end

      section :work_history, "section#app-application-form-work-history" do
        section :add_summary_list,
                GovukSummaryList,
                "#app-check-your-answers-summary-add-work-history"
        sections :work_history_summary_lists,
                 GovukSummaryList,
                 ".govuk-summary-card:not(#app-check-your-answers-summary-add-work-history)"
      end

      section :proof_of_recognition,
              "section#app-application-form-proof-of-recognition" do
        section :registration_number_summary_list,
                GovukSummaryList,
                "#app-check-your-answers-summary-registration-number"
        section :written_statement_summary_list,
                GovukSummaryList,
                "#app-check-your-answers-summary-written-statement"
      end
    end
  end
end
