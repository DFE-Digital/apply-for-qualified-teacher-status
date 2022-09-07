module PageObjects
  module TeacherInterface
    class TaskListItem < SitePrism::Section
      element :link, "a"
      element :status, ".govuk-tag"
    end

    class TaskListSection < SitePrism::Section
      element :heading, "h2"
      sections :task_list_items, TaskListItem, ".app-task-list__item"
    end

    class Application < SitePrism::Page
      set_url "/teacher/application"

      element :heading, "h1"
      element :content_title, "app-task-list_section"
      element :app_task_list, ".app-task-list"

      element :check_answers, ".govuk-button:nth-of-type(1)"
      element :save_and_sign_out, ".govuk-button:nth-of-type(2)"

      sections :task_list_sections, TaskListSection, ".app-task-list>li"

      def find_item(link_text)
        task_list_sections
          .flat_map(&:task_list_items)
          .map(&:link)
          .find { |link| link.text == link_text }
      end

      def click_item(link_text)
        find_item(link_text).click
      end
    end
  end
end
