# frozen_string_literal: true

module PageObjects
  module AssessorInterface
    class EditApplicationHold < SitePrism::Page
      set_url "/assessor/applications/{reference}/application-holds/{application_hold_id}/edit"

      section :form, "form" do
        element :release_comment_textarea,
                "#assessor-interface-release-application-hold-form-release-comment-field"
        element :continue_button, ".govuk-button"
      end
    end
  end
end
