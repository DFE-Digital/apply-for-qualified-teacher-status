# frozen_string_literal: true

module PageObjects
  module SupportInterface
    class EditCountry < SitePrism::Page
      set_url "/support/countries/{id}/edit"
    end
  end
end
