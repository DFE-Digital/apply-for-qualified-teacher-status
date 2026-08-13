# frozen_string_literal: true

module PageObjects
  module SupportInterface
    class RegionPreview < SitePrism::Page
      set_url "/support/regions/{id}/preview"

      element :save_button, "button", text: "Save"

      def click_save
        save_button.click
      end
    end
  end
end
