# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class NewConfirmApplicationHold < SitePrism::Page
      set_url "/assessor/applications/{reference}/application-holds/new-confirm"

      section :form, "form" do
        element :submit_button, ".govuk-button"
      end
    end
  end
end
