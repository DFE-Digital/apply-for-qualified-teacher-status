# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class Applications < SitePrism::Page
      set_url "/assessor/applications"

      section :header, PageHeader, "nav"

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

      section :email_filter, "#app-applications-filters-email" do
        element :email, "input"
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

      section :date_of_birth_filter,
              "#app-applications-filters-date-of-birth" do
        element :day, "#assessor_interface_filter_form_date_of_birth_3i"
        element :month, "#assessor_interface_filter_form_date_of_birth_2i"
        element :year, "#assessor_interface_filter_form_date_of_birth_1i"
      end

      section :action_required_by_filter,
              "#app-applications-filters-action-required-by" do
        sections :items, GovukCheckboxItem, ".govuk-checkboxes__item"
      end

      section :stage_filter, "#app-applications-filters-stage" do
        sections :items, GovukCheckboxItem, ".govuk-checkboxes__item"
      end

      section :show_all_filter, "#app-applications-show-all-applicants" do
        sections :items, GovukCheckboxItem, ".govuk-checkboxes__item"
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
