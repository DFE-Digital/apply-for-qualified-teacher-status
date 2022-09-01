require "support/page_objects/govuk_radio_item"

module PageObjects
  module AssessorInterface
    class CompleteAssessment < SitePrism::Page
      set_url "/assessor/applications/{application_id}/complete-assessment"

      element :heading, "h1"
      sections :new_states, GovukRadioItem, ".govuk-radios__item"
    end
  end
end
