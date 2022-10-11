module PageObjects
  module TeacherInterface
    class CheckYourAnswers < SitePrism::Page
      element :heading, "h1"
      element :content_title, "app-task-list_section"
      element :about_you_section, "section#app-application-form-about-you"
      element :who_you_can_teach_section,
              "section#app-application-form-who-you-can-teach"
      element :work_history_section, "section#app-application-form-work-history"
      element :proof_of_recognition_section,
              "section#app-application-form-proof-of-recognition"
      element :submission_declaration_section,
              "section#app-application-form-submission-declaration"

      element :confirm_no_sanctions, ".govuk-checkboxes__input", visible: false
    end
  end
end
