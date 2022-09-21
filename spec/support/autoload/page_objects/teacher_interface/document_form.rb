module PageObjects
  module TeacherInterface
    class DocumentForm < SitePrism::Page
      element :heading, "h1"
      element :continue_button, ".govuk-button"
    end
  end
end
