module PageObjects
  module AssessorInterface
    class AssignAssessor < SitePrism::Page
      set_url "/assessor/applications/{application_form_id}/assign-assessor"

      element :heading, "h1"
      sections :assessors, PageObjects::GovukRadioItem, ".govuk-radios__item"
      element :continue_button, "button"
    end
  end
end
