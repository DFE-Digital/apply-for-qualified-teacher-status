# frozen_string_literal: true

module PageObjects
  class MojTimelineItem < SitePrism::Section
    element :heading, ".moj-timeline__title"
    element :byline, ".moj-timeline__byline"
    element :date, ".moj-timeline__date"
    element :description, ".moj-timeline__description"

    expected_elements :heading, :byline, :date, :description
  end
end
