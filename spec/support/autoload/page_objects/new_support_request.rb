# frozen_string_literal: true

module PageObjects
  class NewSupportRequest < SitePrism::Page
    set_url "/support-requests/new"

    element :heading, "h1"

    section :form, "form" do
      element :name_input, "#support-request-form-name-field"
      element :email_input, "#support-request-form-email-field"

      element :application_reference_input,
              "#support-request-form-application-reference-field"

      element :progress_update_application_enquiry_radio_item,
              "#support-request-form-application-enquiry-type-progress-update-field",
              visible: false
      element :other_application_enquiry_radio_item,
              "#support-request-form-application-enquiry-type-other-field",
              visible: false

      element :application_submitted_user_radio_item,
              "#support-request-form-user-type-application-submitted-field",
              visible: false
      element :submitting_an_application_user_radio_item,
              "#support-request-form-user-type-submitting-an-application-field",
              visible: false
      element :providing_a_reference_user_radio_item,
              "#support-request-form-user-type-providing-a-reference-field",
              visible: false
      element :other_user_radio_item,
              "#support-request-form-user-type-other-field",
              visible: false

      element :comment_textarea, "#support-request-form-comment-field"

      element :submit_button, "button.govuk-button"
    end
  end
end
