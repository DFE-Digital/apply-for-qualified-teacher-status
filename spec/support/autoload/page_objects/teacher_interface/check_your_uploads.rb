# frozen_string_literal: true

module PageObjects
  module TeacherInterface
    class CheckYourUploads < SitePrism::Page
      element :heading, "h1"
      element :summary_list_row, ".govuk-summary-list__row"
    end
  end
end
