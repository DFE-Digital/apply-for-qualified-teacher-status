module PageObjects
  module TeacherInterface
    class AlternativeNameForm < SitePrism::Page
      element :heading, "h1"
      element :grid, ".govuk-grid-row"
    end
  end
end
