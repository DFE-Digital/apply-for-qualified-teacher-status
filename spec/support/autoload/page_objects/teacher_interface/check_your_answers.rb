module PageObjects
  module TeacherInterface
    class CheckYourAnswers < SitePrism::Page
      set_url "/teacher/application/edit"

      element :heading, "h1"
      element :content_title, "app-task-list_section"

      section :about_you, "#app-application-form-about-you" do
        section :personal_information_summary_list,
                GovukSummaryList,
                "#app-check-your-answers-summary-personal-information"
        section :identification_document_summary_list,
                GovukSummaryList,
                "#app-check-your-answers-summary-identity-document"
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

      section :submission_declaration,
              "#app-application-form-submission-declaration" do
        section :form, "form" do
          element :confirm_no_sanctions,
                  ".govuk-checkboxes__input",
                  visible: false
          element :submit_button, ".govuk-button"
        end
      end
    end
  end
end
