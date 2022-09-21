module PageObjects
  module TeacherInterface
    class CheckYourAnswers < SitePrism::Page
      element :heading, "h1"
      element :content_title, "app-task-list_section"
      element :heading_1, ".govuk-heading-m:nth-of-type(1)"
      element :heading_2, ".govuk-heading-m:nth-of-type(2)"
      element :heading_3, ".govuk-heading-m:nth-of-type(3)"
      element :content, ".govuk-summary-list__card:nth-of-type(4)"
    end
  end
end
