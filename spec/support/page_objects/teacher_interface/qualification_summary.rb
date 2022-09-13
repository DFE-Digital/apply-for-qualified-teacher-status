module PageObjects
  module TeacherInterface
    class QualificationSummary < SitePrism::Page
      element :heading, "h1"
      element :summary_card, ".govuk-summary-list__card:nth-of-type(1)"
    end
  end
end
