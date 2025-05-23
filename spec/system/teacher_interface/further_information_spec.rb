# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Teacher further information", type: :system do
  before do
    given_i_am_authorized_as_a_user(teacher)
    given_there_is_an_application_form
    given_malware_scanning_is_enabled
  end

  it "save and sign out" do
    when_i_visit_the(:teacher_further_information_requested_start_page)
    then_i_see_the(:teacher_further_information_requested_start_page)

    when_i_click_the_start_button
    then_i_see_the(:teacher_further_information_requested_page)
    and_i_see_the_text_task_list_item
    and_i_see_the_document_task_list_item

    when_i_click_the_save_and_sign_out_button
    then_i_see_the(:teacher_signed_out_page)
  end

  it "check your answers" do
    when_i_visit_the(
      :teacher_further_information_requested_page,
      request_id: further_information_request.id,
    )

    when_i_click_the_text_task_list_item
    then_i_see_the(:teacher_further_information_required_page)

    when_i_fill_in_the_response
    and_i_click_continue
    then_i_see_the(:teacher_further_information_requested_page)
    and_i_see_a_completed_text_task_list_item

    when_i_click_the_document_task_list_item
    then_i_see_the(:teacher_further_information_required_page)
    and_i_click_continue
    then_i_see_the(:teacher_upload_document_page)

    when_i_upload_a_file
    then_i_see_the(:teacher_check_document_page)

    when_i_dont_need_to_upload_another_file
    then_i_see_the(:teacher_further_information_requested_page)
    and_i_see_a_completed_document_task_list_item

    when_i_click_the_work_history_contact_task_list_item
    then_i_see_the(:teacher_further_information_required_page)
    when_i_fill_in_the_work_history_contact_response
    and_i_click_continue
    and_i_see_the_completed_work_history_contact_list_item

    when_i_click_the_check_your_answers_button
    then_i_see_the(:teacher_check_further_information_request_answers_page)
    and_i_see_the_check_your_answers_items

    when_i_click_the_text_check_your_answers_item
    and_i_click_continue
    then_i_see_the(:teacher_check_further_information_request_answers_page)

    when_i_click_the_document_check_your_answers_item
    and_i_click_continue
    when_i_dont_need_to_upload_another_file
    then_i_see_the(:teacher_check_further_information_request_answers_page)

    when_i_submit_the_further_information
    then_i_see_the(:teacher_submitted_application_page)
    and_i_see_the_further_information_received_information
    and_i_receive_a_further_information_received_email
  end

  def given_there_is_an_application_form
    application_form
  end

  def when_i_click_the_start_button
    teacher_further_information_requested_start_page.start_button.click
  end

  def and_i_see_the_text_task_list_item
    expect(text_task_list_item.status_tag.text).to eq("Not started")
  end

  def and_i_see_a_completed_text_task_list_item
    expect(text_task_list_item.status_tag.text).to eq("Completed")
  end

  def and_i_see_the_document_task_list_item
    expect(document_task_list_item.status_tag.text).to eq("Not started")
  end

  def and_i_see_a_completed_document_task_list_item
    expect(document_task_list_item.status_tag.text).to eq("Completed")
  end

  def and_i_see_the_completed_work_history_contact_list_item
    expect(work_history_task_list_item.status_tag.text).to eq("Completed")
  end

  def when_i_click_the_text_task_list_item
    text_task_list_item.click
    expect(
      teacher_further_information_required_page.failure_reason_heading.text,
    ).to eq(
      "The subjects you entered are acceptable for QTS, but the uploaded qualifications do not match them.",
    )
  end

  def when_i_click_the_work_history_contact_task_list_item
    work_history_task_list_item.click
    expect(
      teacher_further_information_required_page.failure_reason_heading.text,
    ).to eq("We could not verify 1 or more references you provided.")
  end

  def when_i_click_the_document_task_list_item
    document_task_list_item.click
    expect(
      teacher_further_information_required_page.failure_reason_heading.text,
    ).to eq("Your ID document is illegible or in a format we cannot accept.")
  end

  def when_i_fill_in_the_response
    teacher_further_information_required_page.form.response_textarea.fill_in with:
      "Response"
  end

  def when_i_fill_in_the_work_history_contact_response
    teacher_further_information_required_page.form.contact_name.fill_in with:
      "James"
    teacher_further_information_required_page.form.contact_job.fill_in with:
      "Carpenter"
    teacher_further_information_required_page.form.contact_email.fill_in with:
      "jamescarpenter@sample.com"
  end

  def when_i_upload_a_file
    teacher_upload_document_page.form.original_attachment.attach_file Rails.root.join(
      file_fixture("upload.pdf"),
    )
    teacher_upload_document_page.form.continue_button.click
  end

  def when_i_dont_need_to_upload_another_file
    teacher_check_document_page.form.false_radio_item.input.click
    teacher_check_document_page.form.continue_button.click
  end

  def and_i_click_continue
    teacher_further_information_required_page.form.continue_button.click
  end

  def when_i_click_the_save_and_sign_out_button
    teacher_further_information_requested_page.save_and_sign_out_button.click
  end

  def when_i_click_the_check_your_answers_button
    teacher_further_information_requested_page.check_your_answers_button.click
  end

  def and_i_see_the_check_your_answers_items
    rows =
      teacher_check_further_information_request_answers_page.summary_list.rows

    expect(rows.count).to eq(3)

    expect(rows.first.key.text).to eq(
      "Tell us more about the subjects you can teach",
    )
    expect(rows.second.key.text).to eq("Add work history details")

    expect(rows.last.key.text).to eq("Upload your identity document")
  end

  def when_i_click_the_text_check_your_answers_item
    text_check_answers_item.actions.link.click
  end

  def when_i_click_the_document_check_your_answers_item
    document_check_answers_item.actions.link.click
  end

  def when_i_submit_the_further_information
    teacher_check_further_information_request_answers_page.submit_button.click
  end

  def and_i_see_the_further_information_received_information
    expect(teacher_submitted_application_page.panel.heading.text).to eq(
      "Further information successfully submitted",
    )
    expect(teacher_submitted_application_page.panel.body.text).to eq(
      "Your application reference number\n#{@application_form.reference}",
    )
  end

  def and_i_receive_a_further_information_received_email
    message = ActionMailer::Base.deliveries.last
    expect(message).not_to be_nil

    expect(message.subject).to eq("Your QTS application: information received")
    expect(message.to).to include(application_form.teacher.email)
  end

  def teacher
    @teacher ||= create(:teacher)
  end

  def application_form
    @application_form ||=
      begin
        application_form =
          create(
            :application_form,
            :submitted,
            :with_work_history,
            statuses: %w[waiting_on_further_information],
            teacher:,
          )
        create(
          :assessment,
          :with_further_information_request,
          application_form:,
        )
        application_form
      end
  end

  def further_information_request
    application_form.assessment.further_information_requests.first
  end

  def text_task_list_item
    teacher_further_information_requested_page.task_list.find_item(
      "Tell us more about the subjects you can teach",
    )
  end

  def text_check_answers_item
    teacher_check_further_information_request_answers_page
      .summary_list
      .rows
      .first
  end

  def work_history_task_list_item
    teacher_further_information_requested_page.task_list.find_item(
      "Add work history details",
    )
  end

  def document_task_list_item
    teacher_further_information_requested_page.task_list.find_item(
      "Upload your identity document",
    )
  end

  def document_check_answers_item
    teacher_check_further_information_request_answers_page
      .summary_list
      .rows
      .last
  end
end
