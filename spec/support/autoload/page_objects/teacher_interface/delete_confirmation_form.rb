module PageObjects
  module TeacherInterface
    class DeleteConfirmationForm < SitePrism::Page
      element :heading, "h1"
      element :delete_button, ".govuk-button:"
    end
  end
end
