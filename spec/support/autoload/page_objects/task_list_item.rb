module PageObjects
  class TaskListItem < SitePrism::Section
    element :link, "a"
    element :status_tag, ".govuk-tag"
  end
end
