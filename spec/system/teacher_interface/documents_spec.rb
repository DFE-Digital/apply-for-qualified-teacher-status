require "rails_helper"

RSpec.describe "Teacher documents", type: :system do
  before do
    given_the_service_is_open
    given_i_am_authorized_as_a_user(teacher)
    given_there_is_an_application_form
    given_malware_scanning_is_enabled
  end

  it "uploading and deleting files" do
    when_i_visit_the(:teacher_application_page)
    then_i_see_the(:teacher_application_page)

    when_i_click_written_statement
    then_i_see_document_form

    when_i_upload_a_document
    and_i_click_continue
    then_i_see_the_check_your_uploaded_files_page

    when_i_choose_yes
    and_i_click_continue
    then_i_see_the_next_page_document_form

    when_i_upload_a_document
    and_i_click_continue
    then_i_see_the_check_your_uploaded_files_page_with_three_files

    when_i_click_delete_on_the_first_document
    and_i_choose_no
    and_i_click_continue
    then_i_see_the_check_your_uploaded_files_page_with_three_files

    when_i_click_delete_on_the_first_document
    and_i_choose_yes
    and_i_click_continue
    then_i_see_the_check_your_uploaded_files_page
  end

  def given_there_is_an_application_form
    application_form
  end

  def when_i_click_written_statement
    click_link "Upload your written statement"
  end

  def when_i_upload_a_document
    teacher_upload_document_page.form.original_attachment.attach_file Rails.root.join(
      file_fixture("upload.pdf"),
    )
    teacher_upload_document_page.form.written_in_english_items.second.choose
    teacher_upload_document_page.form.translated_attachment.attach_file Rails.root.join(
      file_fixture("upload.pdf"),
    )
  end

  def when_i_click_delete_on_the_first_document
    first(:link, "Delete").click
  end

  def then_i_see_document_form
    expect(teacher_check_document_page).to have_title("Upload a document")
    expect(teacher_check_document_page.heading.text).to eq(
      "Upload your written statement",
    )
  end

  def then_i_see_the_next_page_document_form
    expect(teacher_check_document_page).to have_title("Upload a document")
    expect(teacher_check_document_page.heading.text).to eq(
      "Upload the next page of your written statement document",
    )
  end

  def then_i_see_the_check_your_uploaded_files_page
    expect(teacher_check_uploaded_files_page).to have_title("Check your uploaded files")
    expect(teacher_check_uploaded_files_page.heading.text).to eq(
      "Check your uploaded files – written statement document",
    )
    expect(teacher_check_uploaded_files_page.files).to have_content(
      "File 1\tupload.pdf (opens in a new tab)\tDelete",
    )
    expect(teacher_check_uploaded_files_page.files).to have_content(
      "File 2\tupload.pdf (opens in a new tab)\tDelete",
    )
  end

  def then_i_see_the_check_your_uploaded_files_page_with_three_files
    then_i_see_the_check_your_uploaded_files_page
    expect(teacher_check_uploaded_files_page.files).to have_content(
      "File 3\tupload.pdf (opens in a new tab)\tDelete",
    )
  end

  def teacher
    @teacher ||= create(:teacher)
  end

  def application_form
    @application_form ||=
      create(:application_form, teacher:, needs_written_statement: true)
  end
end
