module PageObjects
  module TeacherInterface
    class SubmittedApplication < SitePrism::Page
      element :heading_1, ".govuk-heading-xl"
      element :heading_2, ".govuk-panel__title"
      element :reference, ".govuk-panel__body"
    end
  end
end
