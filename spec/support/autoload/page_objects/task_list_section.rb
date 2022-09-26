module PageObjects
  class TaskListSection < SitePrism::Section
    element :heading, "h2"
    sections :items, TaskListItem, ".app-task-list__item"
  end
end
