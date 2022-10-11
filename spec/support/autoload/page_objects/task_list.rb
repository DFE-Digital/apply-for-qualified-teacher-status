module PageObjects
  class TaskList < SitePrism::Section
    sections :sections, TaskListSection, ".app-task-list > li"

    def find_item(text)
      sections.flat_map(&:items).find { |item| item.name.text == text }
    end

    def click_item(link_text)
      find_item(link_text).link.click
    end
  end
end
