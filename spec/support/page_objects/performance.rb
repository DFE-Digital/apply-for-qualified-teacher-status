module PageObjects
  class Performance < SitePrism::Page
    set_url "/performance{?since_launch*}"

    section :live_service_usage, "main > div:nth-of-type(2)" do
      elements :stats, "div > div"

      element :table, "table"
    end
  end
end
