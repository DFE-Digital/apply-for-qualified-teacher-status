module PageObjects
  module TeacherInterface
    class CheckUploadedFiles < SitePrism::Page
      set_url "/teacher/application/documents/{reference}/edit"

      element :heading, ".govuk-heading-xl"
      element :files, ".govuk-grid-row .govuk-grid-column-two-thirds"
      element :continue_button, ".govuk-button"
    end
  end
end
