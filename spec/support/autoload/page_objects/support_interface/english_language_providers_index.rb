# frozen_string_literal: true

module PageObjects
  module SupportInterface
    class EnglishLanguageProvidersIndex < SitePrism::Page
      set_url "/support/english_language_providers"

      sections :english_language_providers, "article" do
        element :name_heading, "h2"
        element :name_link, "a"
      end
    end
  end
end
