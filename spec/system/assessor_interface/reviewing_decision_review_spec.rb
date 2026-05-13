# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor reviewing an incoming decision review request",
               type: :system do
  let(:application_form) do
    create :application_form,
           :with_assessment,
           :declined_with_decision_review_received
  end
  let(:decision_review_request) do
    create :received_decision_review_request,
           assessment: application_form.assessment
  end

  before do
    given_there_is_a_declined_application_form_with_decision_review_request
  end

  it "does not allow any access if staff is archived" do
    given_i_am_authorized_as_a_reverse_decision_archived_user

    when_i_visit_the(
      :assessor_review_decision_review_request_page,
      reference:,
      assessment_id:,
      decision_review_request_id:,
    )
    then_i_see_the_forbidden_page
  end

  it "does not allow access to confirm decision again if already reviewed" do
    given_the_decision_review_request_is_already_reviewed
    given_i_am_authorized_as_a_reverse_decision_user

    when_i_visit_the(
      :assessor_confirm_decision_review_request_page,
      reference:,
      assessment_id:,
      decision_review_request_id:,
    )
    then_i_see_the(
      :assessor_review_decision_review_request_page,
      reference:,
      assessment_id:,
      decision_review_request_id:,
    )
  end

  it "changes decline decision" do
    given_i_am_authorized_as_a_reverse_decision_user

    when_i_visit_the(:assessor_application_page, reference:)
    then_i_see_the_decision_review_request_task
    and_i_see_application_status_is_declined_and_decision_review_received

    when_i_click_on_review_decision_review_task
    then_i_see_the(
      :assessor_review_decision_review_request_page,
      reference:,
      assessment_id:,
      decision_review_request_id:,
    )

    when_i_select_that_applicant_has_provided_enough_evidence
    then_i_see_the(
      :assessor_confirm_decision_review_request_page,
      reference:,
      assessment_id:,
      decision_review_request_id:,
    )
    and_i_see_content_for_changing_the_decline_decision

    when_i_confirm_my_review_for_decision_review_request
    then_i_see_the(
      :assessor_decision_review_request_confirmation_page,
      reference:,
      assessment_id:,
      decision_review_request_id:,
    )
    and_i_see_content_on_what_has_happened_for_changing_decline_decision

    when_i_click_on_see_application_overview
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_the_decision_review_request_task_completed
    and_i_see_application_status_not_to_be_declined
  end

  it "upholds decline decision" do
    given_i_am_authorized_as_a_reverse_decision_user

    when_i_visit_the(:assessor_application_page, reference:)
    then_i_see_the_decision_review_request_task
    and_i_see_application_status_is_declined_and_decision_review_received

    when_i_click_on_review_decision_review_task
    then_i_see_the(
      :assessor_review_decision_review_request_page,
      reference:,
      assessment_id:,
      decision_review_request_id:,
    )

    when_i_select_that_applicant_has_not_provided_enough_evidence
    then_i_see_the(
      :assessor_confirm_decision_review_request_page,
      reference:,
      assessment_id:,
      decision_review_request_id:,
    )
    and_i_see_content_for_upholding_the_decline_decision

    when_i_confirm_my_review_for_decision_review_request
    then_i_see_the(
      :assessor_decision_review_request_confirmation_page,
      reference:,
      assessment_id:,
      decision_review_request_id:,
    )
    and_i_see_content_on_what_has_happened_for_upholding_decline_decision

    when_i_click_on_see_application_overview
    then_i_see_the(:assessor_application_page, reference:)
    and_i_see_the_decision_review_request_task_completed
    and_i_see_application_status_is_declined_only
  end

  private

  def given_there_is_a_declined_application_form_with_decision_review_request
    application_form
    decision_review_request
  end

  def given_the_decision_review_request_is_already_reviewed
    decision_review_request.update!(
      review_passed: false,
      reviewed_at: Time.current,
    )
  end

  def then_i_see_the_decision_review_request_task
    expect(assessor_application_page.review_decision_review_task).to be_visible
    expect(
      assessor_application_page.review_decision_review_task.status_tag.text,
    ).to eq("Not started")
  end

  def and_i_see_the_decision_review_request_task_completed
    expect(assessor_application_page.review_decision_review_task).to be_visible
    expect(
      assessor_application_page.review_decision_review_task.status_tag.text,
    ).to eq("Completed")
  end

  def and_i_see_application_status_is_declined_only
    expect(assessor_application_page.status_summary.value.text).to include(
      "Declined",
    )
    expect(assessor_application_page.status_summary.value.text).not_to include(
      "Received decision review",
    )
  end

  def and_i_see_application_status_is_declined_and_decision_review_received
    expect(assessor_application_page.status_summary.value.text).to include(
      "Declined",
    )
    expect(assessor_application_page.status_summary.value.text).to include(
      "Received decision review",
    )
  end

  def and_i_see_application_status_not_to_be_declined
    expect(assessor_application_page.status_summary.value.text).not_to include(
      "Declined",
    )
    expect(assessor_application_page.status_summary.value.text).not_to include(
      "Received decision review",
    )
  end

  def when_i_click_on_review_decision_review_task
    assessor_application_page.review_decision_review_task.click
  end

  def when_i_select_that_applicant_has_provided_enough_evidence
    assessor_review_decision_review_request_page.submit_yes(
      note: "Applicant has provided enough evidence.",
    )
  end

  def when_i_select_that_applicant_has_not_provided_enough_evidence
    assessor_review_decision_review_request_page.submit_no(
      note: "Assessor personalised note!",
    )
  end

  def and_i_see_content_for_changing_the_decline_decision
    expect(assessor_confirm_decision_review_request_page).to have_content(
      "Are you sure you want to change the decline decision?",
    )
    expect(assessor_confirm_decision_review_request_page).to have_content(
      "Select 'Confirm' to change the decline decision and move the application back into assessment.",
    )
  end

  def and_i_see_content_for_upholding_the_decline_decision
    expect(assessor_confirm_decision_review_request_page).to have_content(
      "Are you sure you want to uphold the decline decision?",
    )
    expect(assessor_confirm_decision_review_request_page).to have_content(
      "Select 'Confirm' to notify the applicant that their request to change the decline decision has been rejected." \
        " They will also receive your note.",
    )
    expect(assessor_confirm_decision_review_request_page).to have_content(
      "Assessor personalised note!",
    )
  end

  def when_i_confirm_my_review_for_decision_review_request
    assessor_confirm_decision_review_request_page.form.submit_button.click
  end

  def and_i_see_content_on_what_has_happened_for_changing_decline_decision
    expect(assessor_decision_review_request_confirmation_page).to have_content(
      "You have moved this application into assessment",
    )
    expect(assessor_decision_review_request_confirmation_page).to have_content(
      "You have changed the decline decision and moved the application back into assessment.",
    )
    expect(assessor_decision_review_request_confirmation_page).to have_content(
      "The applicant will receive an email notifying them that their decision review request has been accepted.",
    )
  end

  def and_i_see_content_on_what_has_happened_for_upholding_decline_decision
    expect(assessor_decision_review_request_confirmation_page).to have_content(
      "Decision review for QTS application #{application_form.reference} has been rejected",
    )
    expect(assessor_decision_review_request_confirmation_page).to have_content(
      "The applicant will receive an email to notify them of this decision alongside your note.",
    )
  end

  def when_i_click_on_see_application_overview
    click_on "See application overview"
  end

  def assessment_id
    application_form.assessment.id
  end

  def reference
    application_form.reference
  end

  def decision_review_request_id
    decision_review_request.id
  end
end
