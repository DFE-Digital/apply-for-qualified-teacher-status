module PageObjects
  module AssessorInterface
    class Timeline < SitePrism::Page
      set_url "/assessor/applications/{reference}/timeline_events"

      element :heading, "h1"
      sections :timeline_items, MojTimelineItem, ".moj-timeline__item"
    end
  end
end
