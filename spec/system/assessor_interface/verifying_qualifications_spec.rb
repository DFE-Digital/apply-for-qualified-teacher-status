# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor verifying qualifications", type: :system do
  before do
    given_i_am_authorized_as_an_admin_user
    given_there_is_an_application_form_with_qualification_request
  end

  it "request consent" do
    when_i_visit_the(:assessor_application_page, reference:)
    and_i_click_the_verify_qualifications_task
    then_i_see_the(:assessor_qualification_requests_page, reference:)
    and_the_check_and_select_consent_method_task_is_not_started

    when_i_click_the_check_and_select_consent_method_task
    then_i_see_the(:assessor_qualification_requests_consent_methods_page)

    when_i_click_the_continue_button
    then_i_see_the(:assessor_consent_qualification_request_page)

    when_i_choose_the_unsigned_consent_method
    then_i_see_the(:assessor_consent_qualification_request_page)

    when_i_choose_a_signed_consent_method
    then_i_see_the(:assessor_qualification_requests_check_consent_methods_page)

    when_i_confirm_the_consent_methods
    then_i_see_the(:assessor_qualification_requests_page, reference:)
    and_the_check_and_select_consent_method_task_is_completed
    and_the_generate_consent_document_task_item_is_not_started
    and_the_upload_consent_document_task_item_is_not_started

    when_i_click_the_generate_consent_document_task
    then_i_see_the(
      :assessor_qualification_requests_unsigned_consent_document_page,
    )

    when_i_check_unsigned_consent_document_generated
    then_i_see_the(:assessor_qualification_requests_page, reference:)
    and_the_generate_consent_document_task_item_is_completed

    when_i_click_the_upload_consent_document_task
    then_i_see_the(:assessor_upload_consent_document_page)

    when_i_upload_the_consent_document
    then_i_see_the(:assessor_qualification_requests_page, reference:)
    and_the_upload_consent_document_task_item_is_completed
    and_the_send_consent_document_to_applicant_task_is_not_started

    when_i_click_the_send_consent_document_to_applicant_task
    then_i_see_the(:assessor_send_signed_consent_documents_page)

    when_i_send_the_signed_consent_documents
    then_i_see_the(:assessor_qualification_requests_page, reference:)
    and_the_send_consent_document_to_applicant_task_is_completed
    and_the_record_applicant_response_task_is_waiting_on

    when_i_go_back_to_overview
    then_i_see_the(:assessor_application_page, reference:)
  end

  it "consent received" do
    given_the_applicant_has_responded_to_the_consent_requests

    when_i_visit_the(:assessor_application_page, reference:)
    and_i_click_the_verify_qualifications_task
    then_i_see_the(:assessor_qualification_requests_page, reference:)
    and_the_record_applicant_response_task_is_received

    when_i_click_the_record_applicant_response_task
    then_i_see_the(:assessor_verify_consent_request_page)
    and_i_submit_yes_on_the_verify_consent_form
    then_i_see_the(:assessor_qualification_requests_page, reference:)
    and_the_record_applicant_response_task_is_accepted

    when_i_click_the_record_applicant_response_task
    then_i_see_the(:assessor_verify_consent_request_page)
    and_i_submit_no_on_the_verify_consent_form
    then_i_see_the(:assessor_verify_failed_consent_request_page, reference:)
    and_i_submit_an_internal_note
    then_i_see_the(:assessor_qualification_requests_page, reference:)
    and_the_record_applicant_response_task_is_review

    when_i_go_back_to_overview
    then_i_see_the(:assessor_application_page, reference:)
  end

  it "request ecctis" do
    given_the_admin_has_accepted_the_consent_requests

    when_i_visit_the(:assessor_application_page, reference:)
    and_i_click_the_verify_qualifications_task
    then_i_see_the(:assessor_qualification_requests_page, reference:)
    and_the_request_ecctis_verification_task_is_not_started
    and_the_record_ecctis_response_task_is_cannot_start

    when_i_click_the_request_ecctis_verification_task
    then_i_see_the(:assessor_request_qualification_request_page)
    and_i_submit_checked_on_the_request_form
    then_i_see_the(:assessor_qualification_requests_page, reference:)
    and_the_request_ecctis_verification_task_is_completed
    and_the_record_ecctis_response_task_is_waiting_on

    when_i_go_back_to_overview
    then_i_see_the(:assessor_application_page, reference:)
  end

  it "ecctis received" do
    given_the_admin_has_accepted_the_consent_requests
    given_the_admin_has_requested_the_qualification_requests

    when_i_visit_the(:assessor_application_page, reference:)
    and_i_click_the_verify_qualifications_task
    then_i_see_the(:assessor_qualification_requests_page, reference:)
    and_the_request_ecctis_verification_task_is_completed
    and_the_record_ecctis_response_task_is_waiting_on

    when_i_click_the_record_ecctis_response_task
    then_i_see_the(:assessor_verify_qualification_request_page)
    and_i_submit_yes_on_the_verify_form
    then_i_see_the(:assessor_qualification_requests_page, reference:)
    and_the_record_ecctis_response_task_is_completed

    when_i_click_the_record_ecctis_response_task
    then_i_see_the(:assessor_verify_qualification_request_page)
    and_i_submit_no_on_the_verify_form
    then_i_see_the(:assessor_verify_failed_qualification_request_page)
    and_i_submit_an_internal_note
    then_i_see_the(:assessor_qualification_requests_page, reference:)
    and_the_record_ecctis_response_task_is_review

    when_i_go_back_to_overview
    then_i_see_the(:assessor_application_page, reference:)
  end

  private

  def given_there_is_an_application_form_with_qualification_request
    application_form
  end

  def given_the_applicant_has_responded_to_the_consent_requests
    assessment.qualification_requests.each do |qualification_request|
      qualification_request.consent_method_signed_ecctis!
      qualification = qualification_request.qualification
      create(:received_consent_request, assessment:, qualification:)
    end
  end

  def given_the_admin_has_accepted_the_consent_requests
    assessment.update!(unsigned_consent_document_generated: true)
    assessment.qualification_requests.each(&:consent_method_unsigned!)
  end

  def given_the_admin_has_requested_the_qualification_requests
    assessment.qualification_requests.each(&:requested!)
  end

  def and_i_click_the_verify_qualifications_task
    assessor_application_page.verify_qualifications_task.click
  end

  def and_the_check_and_select_consent_method_task_is_not_started
    expect(check_and_select_consent_method_task_item.status_tag.text).to eq(
      "Not started",
    )
  end
  def and_i_see_a_waiting_on_status
    expect(assessor_application_page.status_summary.value).to have_text(
      "Waiting on qualification",
    )
  end

  def when_i_click_the_check_and_select_consent_method_task
    check_and_select_consent_method_task_item.click
  end

  def when_i_click_the_continue_button
    assessor_qualification_requests_consent_methods_page.continue_button.click
  end

  def when_i_choose_the_unsigned_consent_method
    assessor_consent_qualification_request_page.submit_unsigned
  end

  def when_i_choose_a_signed_consent_method
    assessor_consent_qualification_request_page.submit_signed_ecctis
  end

  def when_i_confirm_the_consent_methods
    assessor_qualification_requests_check_consent_methods_page.continue_button.click
  end

  def and_the_check_and_select_consent_method_task_is_completed
    expect(check_and_select_consent_method_task_item.status_tag.text).to eq(
      "Completed",
    )
  end

  def and_the_generate_consent_document_task_item_is_not_started
    expect(generate_consent_document_task_item.status_tag.text).to eq(
      "Not started",
    )
  end

  def and_the_upload_consent_document_task_item_is_not_started
    expect(upload_consent_document_task_item.status_tag.text).to eq(
      "Not started",
    )
  end

  def when_i_click_the_generate_consent_document_task
    generate_consent_document_task_item.click
  end

  def when_i_check_unsigned_consent_document_generated
    assessor_qualification_requests_unsigned_consent_document_page.submit_generated
  end

  def and_the_generate_consent_document_task_item_is_completed
    expect(generate_consent_document_task_item.status_tag.text).to eq(
      "Completed",
    )
  end

  def when_i_click_the_upload_consent_document_task
    upload_consent_document_task_item.click
  end

  def when_i_upload_the_consent_document
    assessor_upload_consent_document_page.submit(
      file: Rails.root.join(file_fixture("upload.pdf")),
    )
  end

  def and_the_upload_consent_document_task_item_is_completed
    expect(upload_consent_document_task_item.status_tag.text).to eq("Completed")
  end

  def and_the_send_consent_document_to_applicant_task_is_not_started
    expect(send_consent_document_to_applicant_task_item.status_tag.text).to eq(
      "Not started",
    )
  end

  def when_i_click_the_send_consent_document_to_applicant_task
    send_consent_document_to_applicant_task_item.click
  end

  def when_i_send_the_signed_consent_documents
    assessor_send_signed_consent_documents_page.continue_button.click
  end

  def and_the_send_consent_document_to_applicant_task_is_completed
    expect(send_consent_document_to_applicant_task_item.status_tag.text).to eq(
      "Completed",
    )
  end

  def and_the_record_applicant_response_task_is_waiting_on
    expect(record_applicant_response_task_item.status_tag.text).to eq(
      "Waiting on",
    )
  end

  def and_the_record_applicant_response_task_is_received
    expect(record_applicant_response_task_item.status_tag.text).to eq(
      "Received",
    )
  end

  def when_i_click_the_record_applicant_response_task
    record_applicant_response_task_item.click
  end

  def and_i_submit_yes_on_the_verify_consent_form
    assessor_verify_consent_request_page.submit_yes
  end

  def and_the_record_applicant_response_task_is_accepted
    expect(record_applicant_response_task_item.status_tag.text).to eq(
      "Completed",
    )
  end

  def and_i_submit_no_on_the_verify_consent_form
    assessor_verify_consent_request_page.submit_no
  end

  def and_the_record_applicant_response_task_is_review
    expect(record_applicant_response_task_item.status_tag.text).to eq("Review")
  end

  def and_the_request_ecctis_verification_task_is_not_started
    expect(request_ecctis_verification_task_item.status_tag.text).to eq(
      "Not started",
    )
  end

  def and_the_record_ecctis_response_task_is_cannot_start
    expect(record_ecctis_response_task_item.status_tag.text).to eq(
      "Cannot start",
    )
  end

  def when_i_click_the_request_ecctis_verification_task
    request_ecctis_verification_task_item.click
  end

  def and_i_submit_checked_on_the_request_form
    assessor_request_qualification_request_page.submit_checked
  end

  def and_i_submit_unchecked_on_the_request_form
    assessor_request_qualification_request_page.submit_unchecked
  end

  def and_the_request_ecctis_verification_task_is_completed
    expect(request_ecctis_verification_task_item.status_tag.text).to eq(
      "Completed",
    )
  end

  def and_the_record_ecctis_response_task_is_waiting_on
    expect(record_ecctis_response_task_item.status_tag.text).to eq("Waiting on")
  end

  def when_i_click_the_record_ecctis_response_task
    record_ecctis_response_task_item.click
  end

  def and_i_submit_yes_on_the_verify_form
    assessor_verify_qualification_request_page.submit_yes
  end

  def and_the_record_ecctis_response_task_is_completed
    expect(record_ecctis_response_task_item.status_tag.text).to eq("Completed")
  end

  def and_i_submit_no_on_the_verify_form
    assessor_verify_qualification_request_page.submit_no
  end

  def and_i_submit_an_internal_note
    assessor_verify_failed_qualification_request_page.submit(note: "A note.")
  end

  def and_the_record_ecctis_response_task_is_review
    expect(record_ecctis_response_task_item.status_tag.text).to eq("Review")
  end

  def when_i_go_back_to_overview
    assessor_qualification_requests_page.continue_button.click
  end

  def check_and_select_consent_method_task_item
    assessor_qualification_requests_page.task_lists.first.find_item(
      "Check and select consent method",
    )
  end

  def generate_consent_document_task_item
    assessor_qualification_requests_page.task_lists.second.find_item(
      "Generate consent document",
    )
  end

  def upload_consent_document_task_item
    assessor_qualification_requests_page.task_lists.third.find_item(
      "Upload consent document",
    )
  end

  def send_consent_document_to_applicant_task_item
    assessor_qualification_requests_page.task_lists.third.find_item(
      "Send consent document to applicant",
    )
  end

  def record_applicant_response_task_item
    assessor_qualification_requests_page.task_lists.third.find_item(
      "Record applicant response",
    )
  end

  def request_ecctis_verification_task_item
    assessor_qualification_requests_page.task_lists.second.find_item(
      "Request Ecctis verification",
    )
  end

  def record_ecctis_response_task_item
    assessor_qualification_requests_page.task_lists.second.find_item(
      "Record Ecctis response",
    )
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        :submitted,
        :verification_stage,
        :with_degree_qualification,
      ).tap do |application_form|
        create(
          :assessment,
          :started,
          :verify,
          :with_qualification_requests,
          application_form:,
        )
      end
  end

  delegate :assessment, :reference, to: :application_form
end
