# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class EditApplicationName < SitePrism::Page
      set_url "/assessor/applications/{reference}/name"

      section :form, "form" do
        element :given_names_field,
                "#assessor-interface-application-form-name-form-given-names-field"
        element :family_name_field,
                "#assessor-interface-application-form-name-form-family-name-field"
        element :submit_button, ".govuk-button"
      end
    end
  end
end
