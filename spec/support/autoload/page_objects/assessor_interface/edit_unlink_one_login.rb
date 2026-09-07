# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class EditUnlinkOneLogin < SitePrism::Page
      set_url "/assessor/applications/{reference}/unlink_one_login"

      section :form, "form" do
        element :true_radio_item,
                "#assessor-interface-unlink-one-login-form-confirm-true-field",
                visible: false
        element :false_radio_item,
                "#assessor-interface-unlink-one-login-form-confirm-field",
                visible: false

        element :submit_button, ".govuk-button"
      end
    end
  end
end
