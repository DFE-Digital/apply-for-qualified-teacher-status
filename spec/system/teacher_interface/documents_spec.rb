RSpec.describe "Teacher documents", type: :system do
  before do
    given_the_service_is_open
    given_the_service_allows_teacher_applications
    given_an_active_application
  end

  it "uploading and deleting files" do
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

  def given_an_active_application
    given_an_eligible_eligibility_check_with_written_country_checks
    click_link "Apply for QTS"
    and_i_sign_up
  end

  def when_i_click_written_statement
    click_link "Upload your written statement"
  end

  def when_i_upload_a_document
    attach_file "teacher-interface-upload-form-original-attachment-field",
                Rails.root.join(file_fixture("upload.pdf"))
    choose "No, I’ll upload a translation as well", visible: false
    attach_file "teacher-interface-upload-form-translated-attachment-field",
                Rails.root.join(file_fixture("upload.pdf"))
  end

  def when_i_click_delete_on_the_first_document
    first(:link, "Delete").click
  end

  def then_i_see_document_form
    expect(page).to have_title("Upload a document")
    expect(page).to have_content("Upload your written statement")
  end

  def then_i_see_the_next_page_document_form
    expect(page).to have_title("Upload a document")
    expect(page).to have_content(
      "Upload the next page of your written statement document"
    )
  end

  def then_i_see_the_check_your_uploaded_files_page
    expect(page).to have_title("Check your uploaded files")
    expect(page).to have_content(
      "Check your uploaded files – written statement document"
    )
    expect(page).to have_content("File 1\tupload.pdf\tDelete")
    expect(page).to have_content("File 2\tupload.pdf\tDelete")
  end

  def then_i_see_the_check_your_uploaded_files_page_with_three_files
    then_i_see_the_check_your_uploaded_files_page
    expect(page).to have_content("File 3\tupload.pdf\tDelete")
  end
end
