# frozen_string_literal: true

module PageObjects
  class Personas < SitePrism::Page
    set_url "/personas"

    element :heading, ".govuk-heading-xl"

    section :tabs, ".govuk-tabs" do
      section :list, ".govuk-tabs__list" do
        sections :items, ".govuk-tabs__list-item" do
          element :link, ".govuk-tabs__tab"
        end
      end

      section :panel, ".govuk-tabs__panel:not(.govuk-tabs__panel--hidden)" do
        elements :buttons, ".govuk-button"
      end
    end

    def staff_tab_item
      find_tab_item("Staff")
    end

    def eligible_checks_tab_item
      find_tab_item("Eligible checks")
    end

    def ineligible_checks_tab_item
      find_tab_item("Ineligible checks")
    end

    def teachers_tab_item
      find_tab_item("Teachers")
    end

    def find_tab_item(text)
      tabs.list.items.find { |item| item.text == text }
    end
  end
end
