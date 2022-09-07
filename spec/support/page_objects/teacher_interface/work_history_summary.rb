module PageObjects
  module TeacherInterface
    class WorkHistorySummary < SitePrism::Page
      element :heading, "h1"
      element :summary_card_1, ".govuk-summary-list__card:nth-of-type(1)"
      element :summary_card_2, ".govuk-summary-list__card:nth-of-type(2)"
    end
  end
end
