require "rails_helper"

RSpec.describe "Teacher further information", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_a_user(teacher)
    given_there_is_an_application_form
  end

  it "save and sign out" do
    when_i_visit_the(:further_information_requested_start_page)
    then_i_see_the(:further_information_requested_start_page)

    when_i_click_the_start_button
    then_i_see_the(:further_information_requested_page)
    and_i_see_the_text_task_list_item
    and_i_see_the_document_task_list_item

    when_i_click_the_save_and_sign_out_button
    then_i_see_the(:signed_out_page)
  end

  it "check your answers" do
    when_i_visit_the(
      :further_information_requested_page,
      request_id: further_information_request.id,
    )

    when_i_click_the_text_task_list_item
    then_i_see_the(:further_information_required_page)

    when_i_fill_in_the_response
    and_i_click_continue
    then_i_see_the(:further_information_requested_page)
    and_i_see_a_completed_text_task_list_item

    when_i_click_the_document_task_list_item
    then_i_see_the(:further_information_required_page)
    and_i_click_continue
    then_i_see_the(:upload_document_page)

    when_i_upload_a_file
    then_i_see_the(:document_form_page)

    when_i_dont_need_to_upload_another_file
    then_i_see_the(:further_information_requested_page)
    and_i_see_a_completed_document_task_list_item

    when_i_click_the_check_your_answers_button
    then_i_see_the(:check_further_information_request_answers_page)
    and_i_see_the_check_your_answers_items

    when_i_click_the_text_check_your_answers_item
    and_i_click_continue
    then_i_see_the(:check_further_information_request_answers_page)

    when_i_click_the_document_check_your_answers_item
    and_i_click_continue
    when_i_dont_need_to_upload_another_file
    then_i_see_the(:check_further_information_request_answers_page)

    when_i_submit_the_further_information
    then_i_see_the(:submitted_application_page)
    and_i_see_the_further_information_received_information
    and_i_receive_a_further_information_received_email
  end

  def given_there_is_an_application_form
    application_form
  end

  def when_i_click_the_start_button
    further_information_requested_start_page.start_button.click
  end

  def and_i_see_the_text_task_list_item
    expect(text_task_list_item.status_tag.text).to eq("NOT STARTED")
  end

  def and_i_see_a_completed_text_task_list_item
    expect(text_task_list_item.status_tag.text).to eq("COMPLETED")
  end

  def and_i_see_the_document_task_list_item
    expect(document_task_list_item.status_tag.text).to eq("NOT STARTED")
  end

  def and_i_see_a_completed_document_task_list_item
    expect(document_task_list_item.status_tag.text).to eq("COMPLETED")
  end

  def when_i_click_the_text_task_list_item
    text_task_list_item.link.click
  end

  def when_i_click_the_document_task_list_item
    document_task_list_item.link.click
  end

  def when_i_fill_in_the_response
    further_information_required_page.form.response_textarea.fill_in with:
      "Response"
  end

  def when_i_upload_a_file
    upload_document_page.form.original_attachment.attach_file Rails.root.join(
      file_fixture("upload.pdf"),
    )
    upload_document_page.form.continue_button.click
  end

  def when_i_dont_need_to_upload_another_file
    document_form_page.form.no_radio_item.input.click
    document_form_page.form.continue_button.click
  end

  def and_i_click_continue
    further_information_required_page.form.continue_button.click
  end

  def when_i_click_the_save_and_sign_out_button
    further_information_requested_page.save_and_sign_out_button.click
  end

  def when_i_click_the_check_your_answers_button
    further_information_requested_page.check_your_answers_button.click
  end

  def and_i_see_the_check_your_answers_items
    rows = check_further_information_request_answers_page.summary_list.rows

    expect(rows.count).to eq(2)

    expect(rows.first.key.text).to eq(
      "Tell us more about the subjects you can teach",
    )

    expect(rows.second.key.text).to eq("Upload your identity document")
  end

  def when_i_click_the_text_check_your_answers_item
    text_check_answers_item.actions.link.click
  end

  def when_i_click_the_document_check_your_answers_item
    document_check_answers_item.actions.link.click
  end

  def when_i_submit_the_further_information
    check_further_information_request_answers_page.submit_button.click
  end

  def and_i_see_the_further_information_received_information
    expect(submitted_application_page.panel.title.text).to eq(
      "Further information successfully submitted",
    )
    expect(submitted_application_page.panel.body.text).to eq(
      "Your reference number\n#{ApplicationForm.last.reference}",
    )
  end

  def and_i_receive_a_further_information_received_email
    message = ActionMailer::Base.deliveries.last
    expect(message).to_not be_nil

    expect(message.subject).to eq(
      "We’ve received the additional information you sent us",
    )
    expect(message.to).to include(application_form.teacher.email)
  end

  def teacher
    @teacher ||= create(:teacher, :confirmed)
  end

  def application_form
    @application_form ||=
      create(:application_form, :further_information_requested, teacher:)
  end

  def further_information_request
    application_form.assessment.further_information_requests.first
  end

  def text_task_list_item
    further_information_requested_page.task_list.find_item(
      "Tell us more about the subjects you can teach",
    )
  end

  def text_check_answers_item
    check_further_information_request_answers_page.summary_list.rows.first
  end

  def document_task_list_item
    further_information_requested_page.task_list.find_item(
      "Upload your identity document",
    )
  end

  def document_check_answers_item
    check_further_information_request_answers_page.summary_list.rows.second
  end
end
