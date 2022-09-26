module PageObjects
  class TaskList < SitePrism::Section
    sections :sections, TaskListSection, ".app-task-list > li"

    def find_item(link_text)
      sections
        .flat_map(&:items)
        .map(&:link)
        .find { |link| link.text == link_text }
    end

    def click_item(link_text)
      find_item(link_text).click
    end
  end
end
