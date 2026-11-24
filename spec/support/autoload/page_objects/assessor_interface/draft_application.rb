# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class DraftApplication < SitePrism::Page
      set_url "/assessor/draft-applications/{reference}"

      section :header, PageHeader, "body"
      element :back_link, ".govuk-back-link"
      element :main_content, "main"
    end
  end
end
