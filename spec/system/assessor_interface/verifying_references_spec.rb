# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor verifying references", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_an_admin_user
    given_there_is_an_application_form_with_reference_request
  end

  it "verify received" do
    when_i_visit_the(:assessor_application_page, reference:)
    and_i_click_verify_references
    then_i_see_the(
      :assessor_reference_requests_page,
      reference:,
      assessment_id:,
    )
    and_the_reference_request_status_is("RECEIVED")

    when_i_click_on_the_reference_request
    then_i_see_the(
      :assessor_verify_reference_request_page,
      reference:,
      assessment_id:,
      id: reference_request.id,
    )
    and_i_see_the_reference_summary
    and_i_submit_yes_on_the_verify_form
    then_i_see_the(
      :assessor_reference_requests_page,
      reference:,
      assessment_id:,
    )
    and_the_reference_request_status_is("ACCEPTED")

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
    and_the_reference_request_status_is("REVIEW")

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
    and_the_reference_request_status_is("OVERDUE")

    when_i_click_on_the_reference_request
    then_i_see_the(
      :assessor_verify_reference_request_page,
      reference:,
      assessment_id:,
      id: reference_request.id,
    )
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
    and_the_reference_request_status_is("REVIEW")

    when_i_verify_that_all_references_are_accepted
    then_i_see_the_verify_references_task_is_completed
  end

  private

  def given_there_is_an_application_form_with_reference_request
    application_form
  end

  def given_the_reference_request_is_overdue
    reference_request.update!(expired_at: Time.zone.now, received_at: nil)
  end

  def and_i_click_verify_references
    assessor_application_page.verify_references_task.link.click
  end

  def and_the_reference_request_status_is(status)
    expect(reference_request_task_item.status_tag.text).to eq(status)
  end

  def when_i_click_on_the_reference_request
    reference_request_task_item.click
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
    ).to eq(reference_request.additional_information_response)
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

  def when_i_verify_that_all_references_are_accepted
    assessor_reference_requests_page.continue_button.click
  end

  def then_i_see_the_verify_references_task_is_completed
    expect(
      assessor_reference_requests_page
        .task_list
        .sections
        .first
        .items
        .first
        .status_tag
        .text,
    ).to eq("COMPLETED")
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
            :with_received_professional_standing_request,
            :verify,
            application_form:,
          )
        create(:assessment_section, :passed, assessment:)
        create(
          :reference_request,
          :received,
          :responses_valid,
          assessment:,
          work_history:,
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
