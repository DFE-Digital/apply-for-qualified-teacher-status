module PageObjects
  class TaskListItem < SitePrism::Section
    element :name, "span"
    element :link, "a"
    element :status_tag, ".govuk-tag"

    def_delegator :link, :click
  end
end
