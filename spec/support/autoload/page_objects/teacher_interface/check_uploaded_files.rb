module PageObjects
  module TeacherInterface
    class CheckUploadedFiles < SitePrism::Page
      set_url "/teacher/application/documents/{application_form_id}/edit"

      element :heading, "h1"
      element :files, ".govuk-grid-row .govuk-grid-column-two-thirds"
      element :continue_button, ".govuk-button"
    end
  end
end
