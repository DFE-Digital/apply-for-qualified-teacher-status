module PageObjects
  module AssessorInterface
    class ApplicationStatus < SitePrism::Page
      set_url "/assessor/applications/{reference}/status"

      element :back_link, "a", text: "Back"

      section :panel, GovukPanel, ".govuk-panel"

      section :button_group, ".govuk-button-group" do
        element :list_button, ".govuk-button:not(.govuk-button--secondary)"
        element :overview_button, ".govuk-button.govuk-button--secondary"
      end
    end
  end
end
