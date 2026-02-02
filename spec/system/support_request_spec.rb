# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Support request form", type: :system do
  before do
    allow(Zendesk).to receive(:create_request!).and_return(
      OpenStruct.new(id: "1", created_at: Time.current),
    )
  end

  it "redirects user back to homepage" do
    when_i_visit_the(:new_support_request_page)

    then_i_see_the(:eligibility_start_page)
  end

  context "when support request form feature is enabled" do
    around do |example|
      FeatureFlags::FeatureFlag.activate(:support_request_form)
      example.run
      FeatureFlags::FeatureFlag.deactivate(:support_request_form)
    end

    it "allows the user to submit a request" do
      when_i_visit_the(:new_support_request_page)
      then_i_see_the(:new_support_request_page)

      new_support_request_page.form.name_input.fill_in with: "Test User"
      new_support_request_page.form.email_input.fill_in with: "test@example.com"
      new_support_request_page
        .form
        .submitting_an_application_category_radio_item
        .click

      new_support_request_page.form.comment_textarea.fill_in(
        with: "I need some help submitting my application.",
      )

      new_support_request_page.form.submit_button.click

      then_i_see_the(:support_request_confirmation_page)
    end

    context "with applicant already submitted application" do
      it "allows the user to submit a request with extra information" do
        when_i_visit_the(:new_support_request_page)
        then_i_see_the(:new_support_request_page)

        new_support_request_page.form.name_input.fill_in with: "Test User"
        new_support_request_page.form.email_input.fill_in with:
          "test@example.com"
        new_support_request_page
          .form
          .application_submitted_category_radio_item
          .click

        new_support_request_page.form.application_reference_input.fill_in with:
          "000001"
        new_support_request_page
          .form
          .progress_update_application_enquiry_radio_item
          .click

        new_support_request_page.form.comment_textarea.fill_in(
          with: "I need some help submitting my application.",
        )

        new_support_request_page.form.submit_button.click

        then_i_see_the(:support_request_confirmation_page)
      end
    end
  end
end
