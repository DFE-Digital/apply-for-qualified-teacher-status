# frozen_string_literal: true

module PageObjects
  module SupportInterface
    class RegionPreview < SitePrism::Page
      set_url "/support/regions/{id}/preview"
    end
  end
end
