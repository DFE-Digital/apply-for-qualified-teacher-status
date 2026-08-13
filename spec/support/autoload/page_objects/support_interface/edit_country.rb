# frozen_string_literal: true

module PageObjects
  module SupportInterface
    class EditCountry < SitePrism::Page
      set_url "/support/countries/{id}/edit"

      element :heading, "h1"
      element :other_information_field,
              "#support-interface-country-form-other-information-field"
      element :sanction_information_field,
              "#support-interface-country-form-sanction-information-field"
      element :status_information_field,
              "#support-interface-country-form-status-information-field"
      element :teaching_qualification_information_field,
              "#support-interface-country-form-teaching-qualification-information-field"
      element :region_names_field,
              "#support-interface-country-form-region-names-field"
      element :has_regions_radio_yes,
              "#support-interface-country-form-has-regions-true-field",
              visible: :all
      element :has_regions_radio_no,
              "#support-interface-country-form-has-regions-false-field",
              visible: :all
      element :preview_button, "button", text: "Preview"

      def has_heading?(text)
        heading.has_text?(text)
      end

      def fill_in_other_information(text)
        other_information_field.fill_in(with: text)
      end

      def fill_in_sanction_information(text)
        sanction_information_field.fill_in(with: text)
      end

      def fill_in_status_information(text)
        status_information_field.fill_in(with: text)
      end

      def fill_in_teaching_qualification_information(text)
        teaching_qualification_information_field.fill_in(with: text)
      end

      def select_has_regions
        has_regions_radio_yes.choose
      end

      def select_does_not_have_regions
        has_regions_radio_no.choose
      end

      def fill_in_region_names(names)
        region_names_field.fill_in(with: names)
      end

      def click_preview
        preview_button.click
      end
    end
  end
end
