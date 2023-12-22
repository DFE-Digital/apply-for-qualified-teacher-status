# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor verifying qualifications", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_an_assessor_user
    given_there_is_an_application_form_with_qualification_request
  end

  it "received and passed" do
    when_i_visit_the(:assessor_application_page, reference:)
    and_i_see_a_waiting_on_status
    and_i_click_record_qualifications_task
    then_i_see_the(:assessor_qualification_requests_page, reference:)

    when_i_select_the_first_qualification_request
    then_i_see_the(:assessor_edit_qualification_request_page, reference:)

    when_the_request_is_received_and_passed
    then_i_see_the(:assessor_qualification_requests_page, reference:)

    when_i_go_back_to_overview
    and_i_see_an_in_progress_status
  end

  it "received and not passed" do
    when_i_visit_the(:assessor_application_page, reference:)
    and_i_see_a_waiting_on_status
    and_i_click_record_qualifications_task
    then_i_see_the(:assessor_qualification_requests_page, reference:)

    when_i_select_the_first_qualification_request
    then_i_see_the(:assessor_edit_qualification_request_page, reference:)

    when_the_request_is_received_and_not_passed
    then_i_see_the(:assessor_qualification_requests_page, reference:)

    when_i_go_back_to_overview
    and_i_see_an_in_progress_status
  end

  it "not received and failed" do
    when_i_visit_the(:assessor_application_page, reference:)
    and_i_see_a_waiting_on_status
    and_i_click_record_qualifications_task
    then_i_see_the(:assessor_qualification_requests_page, reference:)

    when_i_select_the_first_qualification_request
    then_i_see_the(:assessor_edit_qualification_request_page, reference:)

    when_the_request_is_not_received_and_failed
    then_i_see_the(:assessor_qualification_requests_page, reference:)

    when_i_go_back_to_overview
    and_i_see_an_in_progress_status
  end

  it "not received and not failed" do
    when_i_visit_the(:assessor_application_page, reference:)
    and_i_see_a_waiting_on_status
    and_i_click_record_qualifications_task
    then_i_see_the(:assessor_qualification_requests_page, reference:)

    when_i_select_the_first_qualification_request
    then_i_see_the(:assessor_edit_qualification_request_page, reference:)

    when_the_request_is_not_received_and_not_failed
    then_i_see_the(:assessor_qualification_requests_page, reference:)

    when_i_go_back_to_overview
    and_i_see_a_waiting_on_status
  end

  private

  def given_there_is_an_application_form_with_qualification_request
    application_form
  end

  def and_i_see_a_waiting_on_status
    expect(assessor_application_page.status_summary.value).to have_text(
      "WAITING ON QUALIFICATION",
    )
  end

  def and_i_click_record_qualifications_task
    assessor_application_page.record_qualification_requests_task.link.click
  end

  def when_i_click_review_qualifications_task
    assessor_application_page.review_qualification_requests_task.link.click
  end

  def when_i_select_the_first_qualification_request
    assessor_qualification_requests_page
      .task_list
      .qualification_requests
      .first
      .click
  end

  def when_the_request_is_received_and_passed
    form = assessor_edit_qualification_request_page.form

    form.received_true_radio_item.choose
    form.passed_true_radio_item.choose
    form.submit_button.click
  end

  def when_the_request_is_received_and_not_passed
    form = assessor_edit_qualification_request_page.form

    form.received_true_radio_item.choose
    form.passed_false_radio_item.choose
    form.note_field.fill_in with: "Note."
    form.submit_button.click
  end

  def when_the_request_is_not_received_and_failed
    form = assessor_edit_qualification_request_page.form

    form.received_false_radio_item.choose
    form.failed_true_radio_item.choose
    form.submit_button.click
  end

  def when_the_request_is_not_received_and_not_failed
    form = assessor_edit_qualification_request_page.form

    form.received_false_radio_item.choose
    form.failed_false_radio_item.choose
    form.submit_button.click
  end

  def when_i_go_back_to_overview
    assessor_qualification_requests_page.continue_button.click
  end

  def and_i_see_a_received_status
    expect(assessor_application_page.status_summary.value).to have_text(
      "RECEIVED",
    )
  end

  def and_i_see_an_in_progress_status
    expect(assessor_application_page.status_summary.value).to have_text(
      "ASSESSMENT IN PROGRESS",
    )
  end

  def application_form
    @application_form ||=
      begin
        application_form =
          create(
            :application_form,
            :submitted,
            statuses: %w[waiting_on_qualification],
          )
        qualification = create(:qualification, :completed, application_form:)
        assessment = create(:assessment, :started, application_form:)
        create(:qualification_request, :requested, assessment:, qualification:)
        application_form
      end
  end

  delegate :reference, to: :application_form
end
