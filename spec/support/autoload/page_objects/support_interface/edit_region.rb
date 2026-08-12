# frozen_string_literal: true

module PageObjects
  module SupportInterface
    class EditRegion < SitePrism::Page
      set_url "/support/regions/{id}/edit"
    end
  end
end
