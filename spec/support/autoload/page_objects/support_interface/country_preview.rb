# frozen_string_literal: true

module PageObjects
  module SupportInterface
    class CountryPreview < SitePrism::Page
      set_url "/support/countries/{id}/preview"
    end
  end
end
