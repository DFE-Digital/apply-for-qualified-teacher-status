# frozen_string_literal: true

module PageObjects
  class GovukTaskList < SitePrism::Section
    sections :items, ".govuk-task-list__item" do
      section :name_and_hint, ".govuk-task-list__name-and-hint" do
        element :link, "a"
      end
      element :status_tag, ".govuk-tag"
    end

    def find_item(text)
      items.find { |item| item.name_and_hint.text == text }
    end

    def click_item(link_text)
      find_item(link_text).click
    end
  end
end
