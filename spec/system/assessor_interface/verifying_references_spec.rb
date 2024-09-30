# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor verifying references", type: :system do
  before do
    given_i_am_authorized_as_an_admin_user
    given_there_is_an_application_form_with_reference_request
  end

  it "does not allow any access if user is archived" do
    given_i_am_authorized_as_an_archived_admin_user

    when_i_visit_the(
      :assessor_reference_requests_page,
      reference:,
      assessment_id:,
    )
    then_i_see_the_forbidden_page
  end

  it "resend emails" do
    when_i_visit_the(:assessor_application_page, reference:)
    and_i_click_verify_references
    then_i_see_the(
      :assessor_reference_requests_page,
      reference:,
      assessment_id:,
    )
    and_the_reference_request_status_is("Waiting on")

    when_i_click_on_the_reference_request
    then_i_see_the(
      :assessor_verify_reference_request_page,
      reference:,
      assessment_id:,
      id: reference_request.id,
    )
    and_i_can_resend_the_email

    when_i_click_on_resend_email_summary
    and_i_click_on_send_email_button
    then_i_see_the(
      :assessor_verify_reference_request_page,
      reference:,
      assessment_id:,
      id: reference_request.id,
    )
  end

  it "verify received" do
    given_the_reference_request_is_received

    when_i_visit_the(:assessor_application_page, reference:)
    and_i_click_verify_references
    then_i_see_the(
      :assessor_reference_requests_page,
      reference:,
      assessment_id:,
    )
    and_the_reference_request_status_is("Received")

    when_i_click_on_the_reference_request
    then_i_see_the(
      :assessor_verify_reference_request_page,
      reference:,
      assessment_id:,
      id: reference_request.id,
    )
    and_i_see_the_reference_summary
    and_i_cant_resend_the_email
    and_i_submit_yes_on_the_verify_form
    then_i_see_the(
      :assessor_reference_requests_page,
      reference:,
      assessment_id:,
    )
    and_the_reference_request_status_is("Completed")

    when_i_click_on_the_reference_request
    then_i_see_the(
      :assessor_verify_reference_request_page,
      reference:,
      assessment_id:,
      id: reference_request.id,
    )
    and_i_see_the_reference_summary
    and_i_submit_no_on_the_verify_form
    then_i_see_the(
      :assessor_verify_failed_reference_request_page,
      reference:,
      assessment_id:,
    )
    and_i_submit_an_internal_note
    then_i_see_the(
      :assessor_reference_requests_page,
      reference:,
      assessment_id:,
    )
    and_the_reference_request_status_is("Review")

    when_i_verify_that_all_references_are_accepted
    then_i_see_the_verify_references_task_is_completed
  end

  it "verify overdue" do
    given_the_reference_request_is_overdue

    when_i_visit_the(:assessor_application_page, reference:)
    and_i_click_verify_references
    then_i_see_the(
      :assessor_reference_requests_page,
      reference:,
      assessment_id:,
    )
    and_the_reference_request_status_is("Overdue")

    when_i_click_on_the_reference_request
    then_i_see_the(
      :assessor_verify_reference_request_page,
      reference:,
      assessment_id:,
      id: reference_request.id,
    )
    and_i_can_resend_the_email
    and_i_submit_yes_on_the_verify_form
    then_i_see_the(
      :assessor_verify_failed_reference_request_page,
      reference:,
      assessment_id:,
    )
    and_i_submit_an_internal_note
    then_i_see_the(
      :assessor_reference_requests_page,
      reference:,
      assessment_id:,
    )
    and_the_reference_request_status_is("Review")

    when_i_verify_that_all_references_are_accepted
    then_i_see_the_verify_references_task_is_completed
  end

  private

  def given_there_is_an_application_form_with_reference_request
    application_form
  end

  def given_the_reference_request_is_received
    reference_request.received!
  end

  def given_the_reference_request_is_overdue
    reference_request.expired!
  end

  def and_i_see_a_waiting_on_status
    expect(assessor_application_page.status_summary.value).to have_text(
      "Waiting on reference",
    )
  end

  def and_i_click_verify_references
    assessor_application_page.verify_references_task.click
  end

  def and_the_reference_request_status_is(status)
    expect(
      assessor_reference_requests_page.task_list.items.first.status_tag.text,
    ).to eq(status)
  end

  def when_i_click_on_the_reference_request
    assessor_reference_requests_page.task_list.items.first.click
  end

  def and_i_see_the_reference_summary
    expect(
      assessor_verify_reference_request_page.summary_list.rows.first.key.text,
    ).to eq("Name of institution")
    expect(
      assessor_verify_reference_request_page.summary_list.rows.first.value.text,
    ).to eq("School")
    expect(
      assessor_verify_reference_request_page.summary_list.rows.second.key.text,
    ).to eq("Number of months")
    expect(
      assessor_verify_reference_request_page
        .summary_list
        .rows
        .second
        .value
        .text,
    ).to match(/\d+/)
    expect(
      assessor_verify_reference_request_page.summary_list.rows.third.key.text,
    ).to eq("Name of reference")
    expect(
      assessor_verify_reference_request_page.summary_list.rows.third.value.text,
    ).to eq(reference_request.work_history.contact_name)

    expect(assessor_verify_reference_request_page.responses.heading.text).to eq(
      "Reference requested",
    )
    expect(
      assessor_verify_reference_request_page.responses.values[0].text,
    ).to eq("John Smith")
    expect(
      assessor_verify_reference_request_page.responses.values[1].text,
    ).to eq("Headteacher")
    expect(
      assessor_verify_reference_request_page.responses.values[2].text,
    ).to eq("Yes")
    expect(
      assessor_verify_reference_request_page.responses.values[3].text,
    ).to eq("Yes")
    expect(
      assessor_verify_reference_request_page.responses.values[4].text,
    ).to eq("Yes")
    expect(
      assessor_verify_reference_request_page.responses.values[5].text,
    ).to eq("Yes")
    expect(
      assessor_verify_reference_request_page.responses.values[6].text,
    ).to eq("Yes")
    expect(
      assessor_verify_reference_request_page.responses.values[7].text,
    ).to eq("Yes")
    expect(
      assessor_verify_reference_request_page.responses.values[8].text,
    ).to eq("No")
    expect(
      assessor_verify_reference_request_page.responses.values[9].text,
    ).to eq("Yes")
    expect(
      assessor_verify_reference_request_page.responses.values[10].text,
    ).to eq("None provided")
  end

  def and_i_cant_resend_the_email
    expect(assessor_verify_reference_request_page).not_to have_css(
      ".govuk-details",
    )
  end

  def and_i_can_resend_the_email
    expect(
      assessor_verify_reference_request_page.send_email_details,
    ).to be_visible
  end

  def and_i_submit_yes_on_the_verify_form
    assessor_verify_reference_request_page.submit_yes
  end

  def and_i_submit_no_on_the_verify_form
    assessor_verify_reference_request_page.submit_no
  end

  def and_i_submit_an_internal_note
    assessor_verify_failed_reference_request_page.submit(note: "A note.")
  end

  def then_i_see_the_reference_request_status_is_accepted
    expect(
      assessor_reference_requests_page.task_list.items.first.status_tag.text,
    ).to eq("Completed")
  end

  def when_i_verify_that_all_references_are_accepted
    assessor_reference_requests_page.continue_button.click
  end

  def then_i_see_the_verify_references_task_is_completed
    expect(
      assessor_application_page.verify_references_task.status_tag.text,
    ).to eq("Completed")
  end

  def when_i_click_on_resend_email_summary
    assessor_verify_reference_request_page.send_email_details.summary.click
  end

  def and_i_click_on_send_email_button
    assessor_verify_reference_request_page.send_email_details.button.click
  end

  def reference_request_task_item
    assessor_reference_requests_page.task_list.sections.first.items.first
  end

  def application_form
    @application_form ||=
      begin
        application_form =
          create(
            :application_form,
            :submitted,
            statuses: %w[waiting_on_reference received_reference],
          )
        work_history =
          create(
            :work_history,
            :completed,
            application_form:,
            contact_job: "Headteacher",
            contact_name: "John Smith",
            school_name: "School",
          )
        assessment =
          create(
            :assessment,
            :with_professional_standing_request,
            :verify,
            application_form:,
          )
        create(:assessment_section, :passed, assessment:)
        create(
          :requested_reference_request,
          assessment:,
          work_history:,
          contact_response: true,
          dates_response: true,
          hours_response: true,
          children_response: true,
          lessons_response: true,
          reports_response: true,
          misconduct_response: false,
          satisfied_response: true,
        )
        application_form
      end
  end

  delegate :reference, to: :application_form

  def assessment_id
    application_form.assessment.id
  end

  def reference_request
    application_form.assessment.reference_requests.first
  end
end
