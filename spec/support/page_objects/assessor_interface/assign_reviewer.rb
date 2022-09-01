require "support/page_objects/govuk_radio_item"

module PageObjects
  module AssessorInterface
    class AssignReviewer < SitePrism::Page
      set_url "/assessor/applications/{application_id}/assign-reviewer"

      element :heading, "h1"
      sections :reviewers, PageObjects::GovukRadioItem, ".govuk-radios__item"
      element :continue_button, "button"
    end
  end
end
