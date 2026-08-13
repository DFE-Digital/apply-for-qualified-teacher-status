# frozen_string_literal: true

module PageObjects
  module SupportInterface
    class NewCountry < SitePrism::Page
      set_url "/support/countries/new"

      element :heading, "h1", text: "Create a new country"
      element :create_button, "button", text: "Create"
      element :country_of_recognition_field,
              "#support-interface-new-country-form-location-field"
      element :eligibility_route_standard_field,
              "#support-interface-new-country-form-eligibility-route-standard-field",
              visible: :all
      element :has_regions_false_field,
              "#support-interface-new-country-form-has-regions-false-field",
              visible: :all
      element :has_regions_true_field,
              "#support-interface-new-country-form-has-regions-true-field",
              visible: :all
      element :region_names_field,
              "#support-interface-new-country-form-region-names-field"

      def has_heading?(text)
        heading.has_text?(text)
      end

      def click_create
        create_button.click
      end

      def select_country_of_recognition(text)
        country_of_recognition_field.select(text)
      end

      def select_eligibility_route_standard
        eligibility_route_standard_field.choose(visible: :all)
      end

      def select_has_regions_false
        has_regions_false_field.choose(visible: :all)
      end

      def select_has_regions_true
        has_regions_true_field.choose(visible: :all)
      end

      def fill_in_region_names(text)
        region_names_field.fill_in(with: text)
      end
    end
  end
end
