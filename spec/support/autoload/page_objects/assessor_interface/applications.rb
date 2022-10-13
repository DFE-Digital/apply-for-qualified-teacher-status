module PageObjects
  module AssessorInterface
    class Applications < SitePrism::Page
      set_url "/assessor/applications"

      section :header, PageHeader, "header"

      section :assessor_filter, "#app-applications-filters-assessor" do
        sections :assessors, GovukCheckboxItem, ".govuk-checkboxes__item"
      end

      section :country_filter, "#app-applications-filters-country" do
        element :country, "input"
      end

      section :reference_filter, "#app-applications-filters-reference" do
        element :reference, "input"
      end

      section :name_filter, "#app-applications-filters-name" do
        element :name, "input"
      end

      section :submitted_at_filter, "#app-applications-filters-submitted-at" do
        element :start_day,
                "#assessor_interface_filter_form_submitted_at_after_3i"
        element :start_month,
                "#assessor_interface_filter_form_submitted_at_after_2i"
        element :start_year,
                "#assessor_interface_filter_form_submitted_at_after_1i"
        element :end_day,
                "#assessor_interface_filter_form_submitted_at_before_3i"
        element :end_month,
                "#assessor_interface_filter_form_submitted_at_before_2i"
        element :end_year,
                "#assessor_interface_filter_form_submitted_at_before_1i"
      end

      section :state_filter, "#app-applications-filters-state" do
        sections :states, GovukCheckboxItem, ".govuk-checkboxes__item"
      end

      sections :search_results, ".app-search-results__item" do
        element :name, "h2"
      end

      element :clear_filters, "div.govuk-button-group a.govuk-link"
      element :apply_filters, "div.govuk-button-group button"

      section :pagination, "nav.govuk-pagination" do
        element :next, "a", text: "Next"
        element :previous, "a", text: "Previous"
      end
    end
  end
end
