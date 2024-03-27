require "rails_helper"

RSpec.describe "Teacher consent", type: :system do
  before do
    given_i_am_authorized_as_a_user(teacher)
    given_there_is_an_application_form
    given_there_is_a_consent_request
  end

  it "save and sign out" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_qualification_consent_start_now_content

    when_i_click_the_start_button
    then_i_see_the(:teacher_consent_requests_page)

    when_i_click_the_save_and_sign_out_button
    then_i_see_the(:teacher_signed_out_page)
    and_i_see_qualification_consent_sign_out_content
  end

  it "check your answers" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_qualification_consent_start_now_content

    when_i_click_the_start_button
    then_i_see_the(:teacher_consent_requests_page)
    and_i_see_the_download_and_upload_tasks

    when_i_click_the_download_task
    then_i_see_the(
      :teacher_download_consent_request_page,
      id: consent_request.id,
    )

    when_i_check_the_downloaded_checkbox
    then_i_see_the(:teacher_consent_requests_page)

    when_i_click_the_upload_task
    then_i_see_the(:teacher_upload_document_page)

    when_i_upload_a_file
    then_i_see_the(:teacher_check_document_page)

    when_i_dont_need_to_upload_another_file
    then_i_see_the(:teacher_consent_requests_page)

    when_i_click_check_your_answers
    then_i_see_the(:teacher_check_consent_requests_page)
    and_i_see_the_documents

    when_i_click_submit
    then_i_see_the(:teacher_application_page)
    and_i_see_the_consent_submitted_status
  end

  def given_there_is_an_application_form
    application_form
  end

  def given_there_is_a_consent_request
    consent_request
  end

  def and_i_see_qualification_consent_start_now_content
    expect(teacher_application_page).to have_content(
      "We need your written consent to verify some of your qualifications",
    )
  end

  def when_i_click_the_start_button
    teacher_application_page.start_now_button.click
  end

  def when_i_click_the_save_and_sign_out_button
    teacher_consent_requests_page.save_and_sign_out_button.click
  end

  def and_i_see_qualification_consent_sign_out_content
    expect(teacher_signed_out_page).to have_content(
      "We’ve saved your progress regarding submitting the written consent",
    )
  end

  def and_i_see_the_download_and_upload_tasks
    task_list = teacher_consent_requests_page.task_list
    expect(task_list.sections.count).to eq(1)

    task_list_section = task_list.sections.first
    expect(task_list_section.items.count).to eq(2)
  end

  def when_i_click_the_download_task
    teacher_consent_requests_page.task_list.sections.first.items.first.click
  end

  def when_i_check_the_downloaded_checkbox
    teacher_download_consent_request_page.downloaded_checkbox.check
    teacher_download_consent_request_page.continue_button.click
  end

  def when_i_click_the_upload_task
    teacher_consent_requests_page.task_list.sections.first.items.second.click
  end

  def when_i_upload_a_file
    teacher_upload_document_page.form.original_attachment.attach_file Rails.root.join(
      file_fixture("upload.pdf"),
    )
    teacher_upload_document_page.form.continue_button.click
  end

  def when_i_dont_need_to_upload_another_file
    teacher_check_document_page.form.continue_button.click
  end

  def when_i_click_check_your_answers
    teacher_consent_requests_page.check_your_answers_button.click
  end

  def and_i_see_the_documents
    expect(teacher_check_consent_requests_page.summary_card).to be_visible
  end

  def when_i_click_submit
    teacher_check_consent_requests_page.submit_button.click
  end

  def and_i_see_the_consent_submitted_status
    expect(teacher_submitted_application_page.panel.title.text).to eq(
      "Consent documents successfully submitted",
    )
    expect(teacher_submitted_application_page.panel.body.text).to eq(
      "Your application reference number\n#{@application_form.reference}",
    )
  end

  def teacher
    @teacher ||= create(:teacher)
  end

  def application_form
    @application_form ||=
      create(
        :application_form,
        :submitted,
        :with_assessment,
        :with_teaching_qualification,
        statuses: %w[waiting_on_consent],
        teacher:,
      )
  end

  def consent_request
    @consent_request ||=
      create(
        :consent_request,
        :requested,
        assessment: application_form.assessment,
        qualification: application_form.qualifications.first,
      )
  end
end
