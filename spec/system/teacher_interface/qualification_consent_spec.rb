require "rails_helper"

RSpec.describe "Teacher qualification consent", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_a_user(teacher)
    given_there_is_an_application_form
    given_there_is_a_qualification_request
  end

  it "save and sign out" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_qualification_consent_start_now_content

    when_i_click_the_start_button
    then_i_see_the(:teacher_qualification_requests_page)

    when_i_click_the_save_and_sign_out_button
    then_i_see_the(:teacher_signed_out_page)
    and_i_see_qualification_consent_sign_out_content
  end

  it "check your answers" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)
    and_i_see_qualification_consent_start_now_content

    when_i_click_the_start_button
    then_i_see_the(:teacher_qualification_requests_page)
    and_i_see_the_download_and_upload_tasks

    when_i_click_the_download_task
    then_i_see_the(
      :teacher_qualification_request_download_page,
      id: qualification_request.id,
    )

    when_i_check_the_downloaded_checkbox
    then_i_see_the(:teacher_qualification_requests_page)
  end

  def given_there_is_an_application_form
    application_form
  end

  def given_there_is_a_qualification_request
    qualification_request
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
    teacher_qualification_requests_page.save_and_sign_out_button.click
  end

  def and_i_see_qualification_consent_sign_out_content
    expect(teacher_signed_out_page).to have_content(
      "We’ve saved your progress regarding submitting the written consent",
    )
  end

  def and_i_see_the_download_and_upload_tasks
    task_list = teacher_qualification_requests_page.task_list
    expect(task_list.sections.count).to eq(1)

    task_list_section = task_list.sections.first
    expect(task_list_section.items.count).to eq(2)
  end

  def when_i_click_the_download_task
    teacher_qualification_requests_page
      .task_list
      .sections
      .first
      .items
      .first
      .click
  end

  def when_i_check_the_downloaded_checkbox
    teacher_qualification_request_download_page.downloaded_checkbox.check
    teacher_qualification_request_download_page.continue_button.click
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
        statuses: %w[waiting_on_qualification],
        teacher:,
      )
  end

  def qualification_request
    @qualification_request ||=
      create(
        :qualification_request,
        :consent_requested,
        assessment: application_form.assessment,
      )
  end
end
