module PageObjects
  class MojTimelineItem < SitePrism::Section
    element :title, ".moj-timeline__title"
    element :byline, ".moj-timeline__byline"
    element :date, ".moj-timeline__date"
    element :description, ".moj-timeline__description"

    expected_elements :title, :byline, :date, :description
  end
end
