module PageObjects
  module TeacherInterface
    class QualificationsForm < SitePrism::Page
      element :heading, "h1"
      element :body, ".govuk-body-l"
    end
  end
end
