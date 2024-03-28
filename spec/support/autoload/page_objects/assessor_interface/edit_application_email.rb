# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class EditApplicationEmail < SitePrism::Page
      set_url "/assessor/applications/{reference}/email"

      section :form, "form" do
        element :email_field,
                "#assessor-interface-application-form-email-form-email-field"
        element :submit_button, ".govuk-button"
      end
    end
  end
end
