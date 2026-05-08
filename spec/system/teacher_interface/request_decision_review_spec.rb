# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher decision review request", type: :system do
  let(:application_form) do
    create(:application_form, :with_assessment, :declined, teacher:)
  end

  let(:teacher) { create :teacher }

  before do
    given_i_am_authorized_as_a_user(teacher)
    given_malware_scanning_is_enabled
  end

  it "allows request for a decision review with supporting evidence" do
    given_a_declined_application_form_exists_within_last_28_days

    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_declined_application_page)
    and_i_see_ability_to_request_a_decision_review

    when_i_click_on_request_decision_review
    then_i_see_the(:teacher_request_decision_review_declaration_page)

    when_i_click_continue
    then_i_see_an_error_message_for_confirm_to_meet_requirements

    when_i_confirm_i_meet_requirements_and_click_continue
    then_i_see_the(:teacher_request_decision_review_new_page)

    when_i_fill_out_the_decision_review_with_supporting_evidence
    then_i_see_the(:teacher_upload_document_page)

    when_i_upload_a_file
    then_i_see_the(:teacher_check_document_page)

    when_i_dont_need_to_upload_another_file
    then_i_see_the(:teacher_request_decision_review_confirm_page)

    when_i_click_change_decision_review_supporting_evidence
    then_i_see_the(:teacher_request_decision_review_edit_page)

    when_i_click_continue
    when_i_dont_need_to_upload_another_file
    then_i_see_the(:teacher_request_decision_review_confirm_page)

    when_i_submit_decision_review
    then_i_see_the(:teacher_request_decision_review_confirmation_page)

    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_declined_application_page)
    and_i_see_content_that_submitted_a_decision_review
  end

  it "allows request for a decision review without supporting evidence" do
    given_a_declined_application_form_exists_within_last_28_days

    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_declined_application_page)
    and_i_see_ability_to_request_a_decision_review

    when_i_click_on_request_decision_review
    then_i_see_the(:teacher_request_decision_review_declaration_page)

    when_i_click_continue
    then_i_see_an_error_message_for_confirm_to_meet_requirements

    when_i_confirm_i_meet_requirements_and_click_continue
    then_i_see_the(:teacher_request_decision_review_new_page)

    when_i_fill_out_the_decision_review_without_supporting_evidence
    then_i_see_the(:teacher_request_decision_review_confirm_page)

    when_i_click_change_decision_review_reason
    then_i_see_the(:teacher_request_decision_review_edit_page)

    when_i_click_continue
    then_i_see_the(:teacher_request_decision_review_confirm_page)

    when_i_click_change_decision_review_supporting_evidence
    then_i_see_the(:teacher_request_decision_review_edit_page)

    when_i_click_continue
    then_i_see_the(:teacher_request_decision_review_confirm_page)

    when_i_submit_decision_review
    then_i_see_the(:teacher_request_decision_review_confirmation_page)

    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_declined_application_page)
    and_i_see_content_that_submitted_a_decision_review
  end

  it "does not allow for a decision review for declined application over 28 days ago" do
    given_a_declined_application_form_exists_over_28_days_ago

    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_declined_application_page)
    and_i_see_that_i_have_missed_the_timeframe_to_request_a_decision_review

    when_i_visit_the(:teacher_request_decision_review_new_page)
    then_i_see_the(:teacher_declined_application_page)
  end

  it "does not allow second decision review request after review not passing on first one" do
    given_a_declined_application_form_exists_within_last_28_days
    and_decision_review_exists_that_did_not_pass_review

    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_declined_application_page)
    and_i_see_my_rejection_reason_for_my_decision_review_request

    when_i_visit_the(:teacher_request_decision_review_new_page)
    then_i_see_the(:teacher_declined_application_page)
  end

  private

  def given_a_declined_application_form_exists_within_last_28_days
    application_form.update!(declined_at: 10.days.ago)
  end

  def given_a_declined_application_form_exists_over_28_days_ago
    application_form.update!(declined_at: 29.days.ago)
  end

  def and_decision_review_exists_that_did_not_pass_review
    create(
      :received_decision_review_request,
      assessment: application_form.assessment,
      review_passed: false,
      reviewed_at: Time.current,
    )
  end

  def and_i_see_ability_to_request_a_decision_review
    expect(teacher_declined_application_page).to have_content(
      "If you disagree with our decision",
    )
    expect(teacher_declined_application_page).to have_content(
      "You must make the request within 28 days of the date we sent the decision email.",
    )
    expect(teacher_declined_application_page).to have_link(
      "Request a decision review",
    )
  end

  def and_i_see_that_i_have_missed_the_timeframe_to_request_a_decision_review
    expect(teacher_declined_application_page).to have_content(
      "If you disagree with our decision",
    )
    expect(teacher_declined_application_page).to have_content(
      "You cannot challenge this decision because it has been more than 28 days since we sent the decision email.",
    )
    expect(teacher_declined_application_page).not_to have_link(
      "Request a decision review",
    )
  end

  def and_i_see_my_rejection_reason_for_my_decision_review_request
    expect(teacher_declined_application_page).to have_content(
      "If you disagree with our decision",
    )
    expect(teacher_declined_application_page).to have_content(
      "Unfortunately your request for a decision review has been rejected.",
    )
    expect(teacher_declined_application_page).not_to have_link(
      "Request a decision review",
    )
  end

  def when_i_click_on_request_decision_review
    teacher_declined_application_page.click_on "Request a decision review"
  end

  def when_i_click_continue
    click_on "Continue"
  end

  def then_i_see_an_error_message_for_confirm_to_meet_requirements
    expect(teacher_request_decision_review_declaration_page).to have_content(
      "Select if your request meets the requirements",
    )
  end

  def when_i_confirm_i_meet_requirements_and_click_continue
    teacher_request_decision_review_declaration_page.form.confirm.click
    when_i_click_continue
  end

  def when_i_fill_out_the_decision_review_without_supporting_evidence
    teacher_request_decision_review_new_page.form.comment_field.fill_in with:
      "There was a mistake in my assessment."
    teacher_request_decision_review_new_page
      .form
      .has_supporting_documents_false_field
      .click

    when_i_click_continue
  end

  def when_i_fill_out_the_decision_review_with_supporting_evidence
    teacher_request_decision_review_new_page.form.comment_field.fill_in with:
      "There was a mistake in my assessment."
    teacher_request_decision_review_new_page
      .form
      .has_supporting_documents_true_field
      .click

    when_i_click_continue
  end

  def when_i_click_change_decision_review_reason
    teacher_request_decision_review_confirm_page
      .summary_rows
      .first
      .find_row(key: "Your decision review reason")
      .actions
      .link
      .click
  end

  def when_i_click_change_decision_review_supporting_evidence
    teacher_request_decision_review_confirm_page
      .summary_rows
      .first
      .find_row(key: "Add supporting evidence")
      .actions
      .link
      .click
  end

  def when_i_submit_decision_review
    teacher_request_decision_review_confirm_page.click_on "Submit request"
  end

  def and_i_see_content_that_submitted_a_decision_review
    expect(teacher_declined_application_page).to have_content(
      "We have received your request for a decision review. " \
        "Your request and evidence will be reviewed by a senior Professional Recognition Manager within 28 working days.",
    )
  end

  def when_i_upload_a_file
    teacher_upload_document_page.form.original_attachment.attach_file Rails.root.join(
      file_fixture("upload.pdf"),
    )
    teacher_upload_document_page.form.written_in_english_items.first.choose
    teacher_upload_document_page.form.continue_button.click
  end

  def when_i_dont_need_to_upload_another_file
    teacher_check_document_page.form.false_radio_item.input.click
    teacher_check_document_page.form.continue_button.click
  end
end
