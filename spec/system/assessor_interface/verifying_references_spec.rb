# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor verifying references", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_application_form_with_reference_request
  end

  it "Verify accepted references" do
    when_i_visit_the(:assessor_application_page, application_id:)
    and_i_see_a_waiting_on_status
    and_i_click_verify_references
    then_i_see_the(:verify_references_page, application_id:)

    when_i_click_on_a_reference_request
    then_i_see_the(
      :reference_request_page,
      application_id:,
      assessment_id:,
      reference_request_id:,
    )
    and_i_see_the_reference_summary

    when_i_verify_the_reference_request
    then_i_see_the_reference_request_status_is_accepted

    when_i_verify_that_all_references_are_accepted
    then_i_see_the_verify_references_task_is_completed
  end

  private

  def given_there_is_an_application_form_with_reference_request
    application_form
  end

  def and_i_see_a_waiting_on_status
    expect(assessor_application_page.overview.status.text).to eq("WAITING ON")
  end

  def and_i_click_verify_references
    assessor_application_page.verify_references_task.link.click
  end

  def when_i_click_on_a_reference_request
    verify_references_page.task_list.reference_requests.first.click
  end

  def and_i_see_the_reference_summary
    expect(reference_request_page.table.headers[0].text).to eq(
      "Name of institution",
    )
    expect(reference_request_page.table.cells[0].text).to eq("School")
    expect(reference_request_page.table.headers[1].text).to eq(
      "Number of months",
    )
    expect(reference_request_page.table.cells[1].text).to eq("38")
    expect(reference_request_page.table.headers[2].text).to eq(
      "Name of reference",
    )
    expect(reference_request_page.table.cells[2].text).to eq(
      reference_request.work_history.contact_name,
    )
    expect(reference_request_page.responses.heading.text).to eq(
      "Reference requested",
    )

    expect(reference_request_page.responses.values[0].text).to eq("John Smith")
    expect(reference_request_page.responses.values[1].text).to eq("Headteacher")
    expect(reference_request_page.responses.values[2].text).to eq("Yes")
    expect(reference_request_page.responses.values[3].text).to eq("Yes")
    expect(reference_request_page.responses.values[4].text).to eq("Yes")
    expect(reference_request_page.responses.values[5].text).to eq("Yes")
    expect(reference_request_page.responses.values[6].text).to eq("Yes")
    expect(reference_request_page.responses.values[7].text).to eq("Yes")
    expect(reference_request_page.responses.values[8].text).to eq("No")
    expect(reference_request_page.responses.values[9].text).to eq("Yes")
    expect(reference_request_page.responses.values[10].text).to eq(
      reference_request.additional_information_response,
    )
  end

  def when_i_verify_the_reference_request
    reference_request_page.form.yes_radio_item.choose
    reference_request_page.form.continue_button.click
  end

  def then_i_see_the_reference_request_status_is_accepted
    expect(verify_references_page.task_list.status_tags.first.text).to eq(
      "ACCEPTED",
    )
  end

  def when_i_verify_that_all_references_are_accepted
    verify_references_page.form.yes_radio_item.choose
    verify_references_page.form.continue_button.click
  end

  def then_i_see_the_verify_references_task_is_completed
    expect(
      assessor_application_page.verify_references_task.status_tag.text,
    ).to eq("COMPLETED")
  end

  def application_form
    @application_form ||=
      begin
        application_form =
          create(:application_form, :waiting_on, received_reference: true)
        create(
          :work_history,
          :completed,
          application_form:,
          contact_name: "John Smith",
          contact_job: "Headteacher",
        )
        assessment =
          create(
            :assessment,
            :with_received_professional_standing_request,
            application_form:,
          )
        create(:assessment_section, :passed, assessment:)
        create(
          :reference_request,
          :received,
          :responses_valid,
          assessment:,
          work_history: assessment.application_form.work_histories.first,
        )
        application_form
      end
  end

  def application_id
    application_form.id
  end

  def assessment_id
    application_form.assessment.id
  end

  def reference_request
    application_form.assessment.reference_requests.first
  end

  def reference_request_id
    reference_request.id
  end
end
