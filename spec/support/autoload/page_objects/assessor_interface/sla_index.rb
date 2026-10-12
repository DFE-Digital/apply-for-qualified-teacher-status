# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class SLAIndex < SitePrism::Page
      set_url "/assessor/service-level-agreements"

      section :breach_status_filter, "#app-sla-filters-breach-statuses" do
        sections :items, GovukCheckboxItem, ".govuk-checkboxes__item"
      end

      element :clear_filters, "div.govuk-button-group a.govuk-link"
      element :apply_filters, "div.govuk-button-group button"

      element :applications_tab_link,
              "#main-content a.govuk-service-navigation__link",
              text: "Applications"
      element :totals_tab_link,
              "#main-content a.govuk-service-navigation__link",
              text: "Totals"

      element :ten_day_sla_tab, "li.govuk-tabs__list-item.ten-day-tab"
      element :forty_day_sla_tab, "li.govuk-tabs__list-item.forty-day-tab"
      element :eighty_day_sla_tab, "li.govuk-tabs__list-item.eighty-day-tab"
    end
  end
end
