# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class WithdrawApplication < SitePrism::Page
      set_url "/assessor/applications/{application_form_id}/withdraw"

      section :form, "form" do
        element :submit_button, ".govuk-button:not(.govuk-button--secondary)"
      end
    end
  end
end
