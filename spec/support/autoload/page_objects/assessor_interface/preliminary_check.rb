# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class PreliminaryCheck < SitePrism::Page
      set_url "/assessor/applications/{application_id}/assessments/{assessment_id}/preliminary-check"

      section :form, "form" do
        element :yes_radio_item,
                "#assessor-interface-preliminary-check-form-preliminary-check-complete-true-field",
                visible: false
        element :continue_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
