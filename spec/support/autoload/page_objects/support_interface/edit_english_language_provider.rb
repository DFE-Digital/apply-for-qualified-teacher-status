# frozen_string_literal: true

module PageObjects
  module SupportInterface
    class EditEnglishLanguageProvider < SitePrism::Page
      set_url "/support/english_language_providers/{id}/edit"

      section :form, "form" do
        element :name_field, "#english-language-provider-name-field"
        element :b2_level_requirement_field,
                "#english-language-provider-b2-level-requirement-field"
        element :reference_name_field,
                "#english-language-provider-reference-name-field"
        element :reference_hint_field,
                "#english-language-provider-reference-hint-field"
        element :accepted_tests_field,
                "#english-language-provider-accepted-tests-field"
        element :check_url_field, "#english-language-provider-check-url-field"
        element :submit_button, ".govuk-button"
      end
    end
  end
end
