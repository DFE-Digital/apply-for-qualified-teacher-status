# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class CreateSuitabilityRecord < SitePrism::Page
      set_url "/assessor/suitability-records/new"

      element :heading, "h1"

      section :form, "form" do
        element :name_field,
                "#assessor-interface-suitability-record-form-name-field"
        element :alias_field,
                "#assessor-interface-suitability-record-form-aliases-field"
        element :location_field,
                "#assessor-interface-suitability-record-form-location-field"
        element :date_of_birth_day_field,
                "#assessor_interface_suitability_record_form_date_of_birth_3i"
        element :date_of_birth_month_field,
                "#assessor_interface_suitability_record_form_date_of_birth_2i"
        element :date_of_birth_year_field,
                "#assessor_interface_suitability_record_form_date_of_birth_1i"
        element :email_field,
                "#assessor-interface-suitability-record-form-emails-field"
        element :reference_field,
                "#assessor-interface-suitability-record-form-references-field"
        element :note_field,
                "#assessor-interface-suitability-record-form-note-field"
        element :submit_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
