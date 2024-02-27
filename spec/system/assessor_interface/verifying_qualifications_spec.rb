# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor verifying qualifications", type: :system do
  before do
    given_the_service_is_open
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

  private

  def given_there_is_an_application_form_with_qualification_request
    application_form
  end

  def given_the_applicant_has_responded_to_the_consent_requests
    assessment.qualification_requests.each do |qualification_request|
      qualification_request.consent_method_signed_ecctis!
      qualification = qualification_request.qualification
      create(:consent_request, :received, assessment:, qualification:)
    end
  end

  def and_i_click_the_verify_qualifications_task
    assessor_application_page.verify_qualifications_task.link.click
  end

  def and_the_check_and_select_consent_method_task_is_not_started
    expect(check_and_select_consent_method_task_item.status_tag.text).to eq(
      "NOT STARTED",
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
      "COMPLETED",
    )
  end

  def and_the_generate_consent_document_task_item_is_not_started
    expect(generate_consent_document_task_item.status_tag.text).to eq(
      "NOT STARTED",
    )
  end

  def and_the_upload_consent_document_task_item_is_not_started
    expect(upload_consent_document_task_item.status_tag.text).to eq(
      "NOT STARTED",
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
      "COMPLETED",
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
    expect(upload_consent_document_task_item.status_tag.text).to eq("COMPLETED")
  end

  def and_the_send_consent_document_to_applicant_task_is_not_started
    expect(send_consent_document_to_applicant_task_item.status_tag.text).to eq(
      "NOT STARTED",
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
      "COMPLETED",
    )
  end

  def and_the_record_applicant_response_task_is_waiting_on
    expect(record_applicant_response_task_item.status_tag.text).to eq(
      "WAITING ON",
    )
  end

  def and_the_record_applicant_response_task_is_received
    expect(record_applicant_response_task_item.status_tag.text).to eq(
      "RECEIVED",
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
      "COMPLETED",
    )
  end

  def and_i_submit_no_on_the_verify_consent_form
    assessor_verify_consent_request_page.submit_no
  end

  def and_i_submit_an_internal_note
    assessor_verify_failed_consent_request_page.submit(note: "A note.")
  end

  def and_the_record_applicant_response_task_is_review
    expect(record_applicant_response_task_item.status_tag.text).to eq("REVIEW")
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
