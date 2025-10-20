# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class EditConfirmApplicationHold < SitePrism::Page
      set_url "/assessor/applications/{reference}/application-holds/{application_hold_id}/edit-confirm"

      section :form, "form" do
        element :submit_button, ".govuk-button"
      end
    end
  end
end
