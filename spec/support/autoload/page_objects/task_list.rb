module PageObjects
  class TaskList < SitePrism::Section
    element :not_started_status, ".govuk-tag.govuk-tag--grey"
    element :accepted_status, ".govuk-tag.govuk-tag--green"

    sections :sections, TaskListSection, ".app-task-list > li"

    def find_item(text)
      sections.flat_map(&:items).find { |item| item.name.text == text }
    end

    def click_item(link_text)
      find_item(link_text).click
    end
  end
end
