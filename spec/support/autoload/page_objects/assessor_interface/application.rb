module PageObjects
  module AssessorInterface
    class Application < SitePrism::Page
      set_url "/assessor/applications/{application_id}"

      element :back_link, "a", text: "Back"

      section :overview, "#app-application-overview" do
        element :name, "div:nth-of-type(1) > dd:nth-of-type(1)"
        element :assessor_name, "div:nth-of-type(6) > dd:nth-of-type(1)"
        element :reviewer_name, "div:nth-of-type(7) > dd:nth-of-type(1)"
        element :status, "div:nth-of-type(9) > dd:nth-of-type(1)"
      end

      section :task_list, "ol.app-task-list" do
        sections :tasks, "ol.app-task-list > li" do
          sections :items,
                   "ol.app-task-list > li > ul.app-task-list__items > li.app-task-list__item" do
            element :heading, "h2"
            element :link, "a"
            element :status, "strong"
          end
        end
      end

      def personal_information_task
        task_item_for("Check personal information")
      end

      def qualifications_task
        task_item_for("Check qualifications")
      end

      private

      def task_item_for(link_text)
        task_list.tasks.first.items.find { |item| item.link.text == link_text }
      end
    end
  end
end
