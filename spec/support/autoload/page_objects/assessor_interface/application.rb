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
          sections :items, "li.app-task-list__item" do
            section :name, ".app-task-list__task-name" do
              element :link, "a"
            end

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

      def work_history_task
        task_item_for("Check work history")
      end

      def professional_standing_task
        task_item_for("Check professional standing")
      end

      private

      def task_item_for(text)
        task_list.tasks.first.items.find { |item| item.name.text == text }
      end
    end
  end
end
