# frozen_string_literal: true

module PageObjects
  module SupportInterface
    class CountriesIndex < SitePrism::Page
      set_url "/support/countries"

      element :heading, "h1", text: "Countries"
      element :add_a_new_country_link, "a", text: "Add a new country"

      def click_country(name)
        click_link(name)
      end

      def has_country?(name)
        has_link?(name)
      end

      def click_region(name)
        click_link(name)
      end

      def has_region?(name)
        has_link?(name)
      end
    end
  end
end
