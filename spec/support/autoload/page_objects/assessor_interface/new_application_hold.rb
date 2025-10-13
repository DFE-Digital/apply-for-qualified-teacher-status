# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class NewApplicationHold < SitePrism::Page
      set_url "/assessor/applications/{reference}/application-holds/new"

      section :form, "form" do
        sections :hold_reason_radio_items,
                 PageObjects::GovukRadioItem,
                 ".govuk-radios__item"
        element :hold_other_reason_comment_textarea,
                "#assessor-interface-create-application-hold-form-reason-comment-field"
        element :continue_button, ".govuk-button"
      end
    end
  end
end
