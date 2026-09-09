# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Feedback submission", type: :system do
  it "allows a user to submit feedback" do
    when_i_visit_the(:new_feedback_submission_page)
    then_i_see_the(:new_feedback_submission_page)

    new_feedback_submission_page
      .form
      .submitting_an_application_application_status_radio_item
      .click

    new_feedback_submission_page
      .form
      .highly_satisfied_overall_experience_radio_item
      .click

    new_feedback_submission_page.form.comment_textarea.fill_in(
      with: "Great service!",
    )

    new_feedback_submission_page.form.submit_button.click

    then_i_see_the(:feedback_confirmation_page)
    expect(feedback_confirmation_page).to have_close_page_message
    expect(feedback_confirmation_page).to have_no_return_to_application_link
  end

  context "when I'm logged in as an applicant" do
    let(:teacher) { create(:teacher) }

    before { given_i_am_authorized_as_a_user(teacher) }

    it "displays return to your application link on confirmation page" do
      when_i_visit_the(:new_feedback_submission_page)
      then_i_see_the(:new_feedback_submission_page)

      new_feedback_submission_page
        .form
        .submitting_an_application_application_status_radio_item
        .click

      new_feedback_submission_page
        .form
        .highly_satisfied_overall_experience_radio_item
        .click

      new_feedback_submission_page.form.comment_textarea.fill_in(
        with: "Great service!",
      )

      new_feedback_submission_page.form.submit_button.click

      then_i_see_the(:feedback_confirmation_page)

      expect(feedback_confirmation_page).to have_return_to_application_link
    end
  end
end
