require "rails_helper"

RSpec.describe "Teacher application", type: :system do
  before do
    given_the_service_is_open
    given_the_service_is_startable
    given_the_service_allows_teacher_applications
  end

  it "allows making an application for a country with no checks" do
    given_an_eligible_eligibility_check_with_none_country_checks

    when_i_click_apply_for_qts
    and_i_sign_up
    then_i_see_the_new_application_page
    and_i_click_continue
    then_i_see_the_active_application_page
    and_i_see_the_work_history_is_not_started

    when_i_click_personal_information
    then_i_see_the_name_and_date_of_birth_form

    when_i_fill_in_the_name_and_date_of_birth_form
    and_i_click_continue
    then_i_see_the_alternative_name_form

    when_i_fill_in_the_alternative_name_form
    and_i_click_continue
    then_i_see_the_upload_name_change_form

    when_i_fill_in_the_upload_name_change_form
    and_i_click_continue
    then_i_see_the_check_your_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_the_personal_information_summary

    when_i_click_continue
    then_i_see_completed_personal_information_section

    when_i_click_identity_document
    then_i_see_the_upload_identification_form

    when_i_fill_in_the_upload_identification_form
    and_i_click_continue
    then_i_see_the_check_your_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_completed_identity_document_section

    when_i_click_qualifications
    then_i_see_the_qualifications_form

    when_i_fill_in_qualifications
    and_i_click_continue
    then_i_see_the_upload_certificate_form

    when_i_fill_in_the_upload_certificate_form
    and_i_click_continue
    then_i_see_the_check_your_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_the_upload_transcript_form

    when_i_fill_in_the_upload_transcript_form
    and_i_click_continue
    then_i_see_the_check_your_uploads

    when_i_choose_no
    and_i_click_continue

    when_i_choose_yes
    and_i_click_continue
    then_i_see_the_qualifications_summary

    when_i_click_continue
    and_i_choose_no
    and_i_click_continue
    then_i_see_completed_qualifications_section

    when_i_click_age_range
    then_i_see_the_age_range_form

    when_i_fill_in_age_range
    and_i_click_continue
    then_i_see_the_age_range_summary

    when_i_click_continue
    then_i_see_completed_age_range_section

    when_i_click_work_history
    then_i_see_the_has_work_history_form

    when_i_fill_in_has_work_history
    and_i_click_continue
    then_i_see_the_work_history_form

    when_i_fill_in_work_history
    and_i_click_continue
    then_i_see_the_work_history_summary

    when_i_click_continue
    and_i_choose_no
    and_i_click_continue
    then_i_see_completed_work_history_section

    when_i_click_check_your_answers
    then_i_see_the_check_your_answers_page
    and_i_see_check_your_work_history

    when_i_click_submit
    then_i_see_the_submitted_application_page
  end

  it "allows making an application for a country with online checks" do
    given_an_eligible_eligibility_check_with_online_country_checks

    when_i_click_apply_for_qts
    and_i_sign_up
    then_i_see_the_new_application_page
    and_i_click_continue
    then_i_see_the_active_application_page
    and_i_see_the_registration_number_is_not_started

    when_i_click_personal_information
    then_i_see_the_name_and_date_of_birth_form

    when_i_fill_in_the_name_and_date_of_birth_form
    and_i_click_continue
    then_i_see_the_alternative_name_form

    when_i_fill_in_the_alternative_name_form
    and_i_click_continue
    then_i_see_the_upload_name_change_form

    when_i_fill_in_the_upload_name_change_form
    and_i_click_continue
    then_i_see_the_check_your_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_the_personal_information_summary

    when_i_click_continue
    then_i_see_completed_personal_information_section

    when_i_click_identity_document
    then_i_see_the_upload_identification_form

    when_i_fill_in_the_upload_identification_form
    and_i_click_continue
    then_i_see_the_check_your_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_completed_identity_document_section

    when_i_click_qualifications
    then_i_see_the_qualifications_form

    when_i_fill_in_qualifications
    and_i_click_continue
    then_i_see_the_upload_certificate_form

    when_i_fill_in_the_upload_certificate_form
    and_i_click_continue
    then_i_see_the_check_your_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_the_upload_transcript_form

    when_i_fill_in_the_upload_transcript_form
    and_i_click_continue
    then_i_see_the_check_your_uploads

    when_i_choose_no
    and_i_click_continue

    when_i_choose_yes
    and_i_click_continue
    then_i_see_the_qualifications_summary

    when_i_click_continue
    and_i_choose_no
    and_i_click_continue
    then_i_see_completed_qualifications_section

    when_i_click_age_range
    then_i_see_the_age_range_form

    when_i_fill_in_age_range
    and_i_click_continue
    then_i_see_the_age_range_summary

    when_i_click_continue
    then_i_see_completed_age_range_section

    when_i_click_registration_number
    then_i_see_the_registration_number_form

    when_i_fill_in_registration_number
    and_i_click_continue
    then_i_see_the_registration_number_summary

    when_i_click_continue
    then_i_see_completed_registration_number_section

    when_i_click_check_your_answers
    then_i_see_the_check_your_answers_page
    and_i_see_check_proof_of_recognition

    when_i_click_submit
    then_i_see_the_submitted_application_page
  end

  it "allows making an application for a country with written checks" do
    given_an_eligible_eligibility_check_with_written_country_checks

    when_i_click_apply_for_qts
    and_i_sign_up
    then_i_see_the_new_application_page
    and_i_click_continue
    then_i_see_the_active_application_page
    and_i_see_the_written_statement_is_not_started

    when_i_click_personal_information
    then_i_see_the_name_and_date_of_birth_form

    when_i_fill_in_the_name_and_date_of_birth_form
    and_i_click_continue
    then_i_see_the_alternative_name_form

    when_i_fill_in_the_alternative_name_form
    and_i_click_continue
    then_i_see_the_upload_name_change_form

    when_i_fill_in_the_upload_name_change_form
    and_i_click_continue
    then_i_see_the_check_your_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_the_personal_information_summary

    when_i_click_continue
    then_i_see_completed_personal_information_section

    when_i_click_identity_document
    then_i_see_the_upload_identification_form

    when_i_fill_in_the_upload_identification_form
    and_i_click_continue
    then_i_see_the_check_your_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_completed_identity_document_section

    when_i_click_qualifications
    then_i_see_the_qualifications_form

    when_i_fill_in_qualifications
    and_i_click_continue
    then_i_see_the_upload_certificate_form

    when_i_fill_in_the_upload_certificate_form
    and_i_click_continue
    then_i_see_the_check_your_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_the_upload_transcript_form

    when_i_fill_in_the_upload_transcript_form
    and_i_click_continue
    then_i_see_the_check_your_uploads

    when_i_choose_no
    and_i_click_continue

    when_i_choose_yes
    and_i_click_continue
    then_i_see_the_qualifications_summary

    when_i_click_continue
    and_i_choose_no
    and_i_click_continue
    then_i_see_completed_qualifications_section

    when_i_click_age_range
    then_i_see_the_age_range_form

    when_i_fill_in_age_range
    and_i_click_continue
    then_i_see_the_age_range_summary

    when_i_click_continue
    then_i_see_completed_age_range_section

    when_i_click_written_statement
    then_i_see_the_upload_written_statement_form

    when_i_fill_in_the_upload_written_statement_form
    and_i_click_continue
    then_i_see_the_check_your_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_completed_written_statement_section

    when_i_click_check_your_answers
    then_i_see_the_check_your_answers_page
    and_i_see_check_proof_of_recognition

    when_i_click_submit
    then_i_see_the_submitted_application_page
  end

  it "allows deleting work history" do
    given_an_eligible_eligibility_check_with_none_country_checks

    when_i_click_apply_for_qts
    and_i_sign_up
    then_i_see_the_new_application_page
    and_i_click_continue
    then_i_see_the_active_application_page
    and_i_see_the_work_history_is_not_started

    when_i_click_work_history
    then_i_see_the_has_work_history_form

    when_i_fill_in_has_work_history
    and_i_click_continue
    then_i_see_the_work_history_form

    when_i_fill_in_work_history
    and_i_click_continue
    then_i_see_the_work_history_summary

    when_i_click_delete
    then_i_see_delete_confirmation_form

    when_i_choose_yes
    and_i_click_continue
    then_i_see_the_work_history_form
  end

  it "allows delete qualifications" do
    given_an_eligible_eligibility_check_with_none_country_checks

    when_i_click_apply_for_qts
    and_i_sign_up
    then_i_see_the_new_application_page
    and_i_click_continue
    then_i_see_the_active_application_page
    and_i_see_the_work_history_is_not_started

    when_i_click_qualifications
    then_i_see_the_qualifications_form

    when_i_fill_in_qualifications
    and_i_click_continue
    then_i_see_the_upload_certificate_form

    when_i_fill_in_the_upload_certificate_form
    and_i_click_continue
    then_i_see_the_check_your_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_the_upload_transcript_form

    when_i_fill_in_the_upload_transcript_form
    and_i_click_continue
    then_i_see_the_check_your_uploads

    when_i_choose_no
    and_i_click_continue

    when_i_choose_yes
    and_i_click_continue
    then_i_see_the_qualifications_summary

    when_i_click_continue
    and_i_choose_yes
    and_i_click_continue
    then_i_see_the_degree_qualifications_form

    when_i_fill_in_qualifications
    and_i_click_continue
    then_i_see_the_upload_degree_certificate_form

    when_i_fill_in_the_upload_certificate_form
    and_i_click_continue
    then_i_see_the_check_your_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_the_upload_degree_transcript_form

    when_i_fill_in_the_upload_transcript_form
    and_i_click_continue
    then_i_see_the_check_your_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_the_qualifications_summary

    when_i_click_delete
    then_i_see_delete_confirmation_form

    when_i_choose_yes
    and_i_click_continue
    then_i_see_the_qualifications_summary
  end

  private

  def when_i_click_apply_for_qts
    click_link "Apply for QTS"
  end

  def when_i_click_start_now
    click_button "Start now"
  end

  def when_i_click_check_your_answers
    click_link "Check your answers"
  end

  def when_i_click_submit
    click_button "Submit your application"
  end

  def when_i_click_continue
    click_link "Continue"
  end

  def when_i_click_personal_information
    click_link "Enter your personal information"
  end

  def when_i_fill_in_the_name_and_date_of_birth_form
    fill_in "teacher-interface-name-and-date-of-birth-form-given-names-field",
            with: "Name"
    fill_in "teacher-interface-name-and-date-of-birth-form-family-name-field",
            with: "Name"
    fill_in "teacher_interface_name_and_date_of_birth_form_date_of_birth_3i",
            with: "1"
    fill_in "teacher_interface_name_and_date_of_birth_form_date_of_birth_2i",
            with: "1"
    fill_in "teacher_interface_name_and_date_of_birth_form_date_of_birth_1i",
            with: "2000"
  end

  def when_i_fill_in_the_alternative_name_form
    choose "Yes – I’ll upload another document to prove this", visible: false
    fill_in "teacher-interface-alternative-name-form-alternative-given-names-field",
            with: "Name"
    fill_in "teacher-interface-alternative-name-form-alternative-family-name-field",
            with: "Name"
  end

  def when_i_fill_in_the_upload_name_change_form
    attach_file "teacher-interface-upload-form-original-attachment-field",
                Rails.root.join(file_fixture("upload.pdf"))
  end

  def when_i_click_identity_document
    click_link "Upload your identity document"
  end

  def when_i_fill_in_the_upload_identification_form
    attach_file "teacher-interface-upload-form-original-attachment-field",
                Rails.root.join(file_fixture("upload.pdf"))
  end

  def when_i_click_qualifications
    click_link "Add your teaching qualifications"
  end

  def when_i_fill_in_qualifications
    fill_in "qualification-title-field", with: "Title"
    fill_in "qualification-institution-name-field", with: "Name"
    fill_in "qualification-institution-country-field", with: "Country"
    fill_in "qualification_start_date_2i", with: "1"
    fill_in "qualification_start_date_1i", with: "2000"
    fill_in "qualification_complete_date_2i", with: "1"
    fill_in "qualification_complete_date_1i", with: "2020"
    fill_in "qualification_certificate_date_2i", with: "1"
    fill_in "qualification_certificate_date_1i", with: "2000"
  end

  def when_i_fill_in_the_upload_certificate_form
    attach_file "teacher-interface-upload-form-original-attachment-field",
                Rails.root.join(file_fixture("upload.pdf"))
  end

  def when_i_fill_in_the_upload_transcript_form
    attach_file "teacher-interface-upload-form-original-attachment-field",
                Rails.root.join(file_fixture("upload.pdf"))
  end

  def when_i_click_age_range
    click_link "Enter the age range you can teach"
  end

  def when_i_fill_in_age_range
    fill_in "teacher-interface-age-range-form-age-range-min-field", with: "7"
    fill_in "teacher-interface-age-range-form-age-range-max-field", with: "11"
  end

  def when_i_click_work_history
    click_link "Add your work history"
  end

  def when_i_fill_in_has_work_history
    choose "Yes", visible: false
  end

  def when_i_fill_in_work_history
    fill_in "work-history-school-name-field", with: "School name"
    fill_in "work-history-city-field", with: "City"
    fill_in "work-history-country-field", with: "Country"
    fill_in "work-history-job-field", with: "Job"
    fill_in "work-history-email-field", with: "test@example.com"
    fill_in "work_history_start_date_2i", with: "1"
    fill_in "work_history_start_date_1i", with: "2000"
    choose "Yes", visible: false
  end

  def when_i_click_registration_number
    click_link "Enter your registration number"
  end

  def when_i_fill_in_registration_number
    fill_in "teacher-interface-registration-number-form-registration-number-field",
            with: "ABC"
  end

  def when_i_click_written_statement
    click_link "Upload your written statement"
  end

  def when_i_click_delete
    click_link "Delete"
  end

  def when_i_fill_in_the_upload_written_statement_form
    attach_file "teacher-interface-upload-form-original-attachment-field",
                Rails.root.join(file_fixture("upload.pdf"))
  end

  def then_i_see_the_new_application_page
    expect(page).to have_current_path("/teacher/application_form/new")
    expect(page).to have_title(
      "In which country are you currently recognised as a teacher?"
    )
    expect(page).to have_content(
      "In which country are you currently recognised as a teacher?"
    )
  end

  def then_i_see_the_active_application_page
    expect(page).to have_current_path("/teacher/application_form")
    expect(page).to have_title("Apply for qualified teacher status (QTS)")
    expect(page).to have_content("Apply for qualified teacher status (QTS)")

    expect(page).to have_content("About you")
    expect(page).to have_content("Enter your personal information\nNOT STARTED")
    expect(page).to have_content("Upload your identity document\nNOT STARTED")

    expect(page).to have_content("Your qualifications")
    expect(page).to have_content(
      "Enter the age range you can teach\nNOT STARTED"
    )

    expect(page).to have_content("Check your answers")
  end

  def and_i_see_the_work_history_is_not_started
    expect(page).to have_content("Your work history")
    expect(page).to have_content("Add your work history\nNOT STARTED")
  end

  def and_i_see_the_written_statement_is_not_started
    expect(page).to have_content("Proof that you’re recognised as a teacher")
    expect(page).to have_content("Upload your written statement\nNOT STARTED")
  end

  def and_i_see_the_registration_number_is_not_started
    expect(page).to have_content("Proof that you’re recognised as a teacher")
    expect(page).to have_content("Enter your registration number\nNOT STARTED")
  end

  def then_i_see_the_name_and_date_of_birth_form
    expect(page).to have_title("About you")
    expect(page).to have_content("Personal information")
    expect(page).to have_content("Given names")
    expect(page).to have_content("Family name")
    expect(page).to have_content("Date of birth")
  end

  def then_i_see_the_alternative_name_form
    expect(page).to have_title("About you")
    expect(page).to have_content(
      "Does your name appear differently on your ID documents or qualifications?"
    )
    expect(page).to have_content(
      "Yes – I’ll upload another document to prove this"
    )
    expect(page).to have_content("No")
  end

  def then_i_see_the_upload_name_change_form
    expect(page).to have_title("Upload a document")
    expect(page).to have_content("Upload a valid identification document")
  end

  def then_i_see_the_upload_identification_form
    expect(page).to have_title("Upload a document")
    expect(page).to have_content("Upload a valid identification document")
  end

  def then_i_see_the_check_your_uploads
    expect(page).to have_title("Check your uploaded files")
    expect(page).to have_content("Check your uploaded files")
    expect(page).to have_content("File 1\tupload.pdf\tDelete")
  end

  def then_i_see_the_qualifications_form
    expect(page).to have_title("Your qualifications")
    expect(page).to have_content("Your teaching qualification")
    expect(page).to have_content(
      "This is the qualification that led to you being recognised as a teacher."
    )
  end

  def then_i_see_the_degree_qualifications_form
    expect(page).to have_title("Your qualifications")
    expect(page).to have_content("Your university degree")
    expect(page).to have_content(
      "Tell us about your university degree qualification."
    )
  end

  def then_i_see_the_upload_certificate_form
    expect(page).to have_title("Upload a document")
    expect(page).to have_content(
      "Upload your teaching qualification certificate"
    )
  end

  def then_i_see_the_upload_degree_certificate_form
    expect(page).to have_title("Upload a document")
    expect(page).to have_content("Upload your university degree certificate")
  end

  def then_i_see_the_upload_transcript_form
    expect(page).to have_title("Upload a document")
    expect(page).to have_content(
      "Upload your teaching qualification transcript"
    )
  end

  def then_i_see_the_upload_degree_transcript_form
    expect(page).to have_title("Upload a document")
    expect(page).to have_content("Upload your university degree transcript")
  end

  def then_i_see_the_age_range_form
    expect(page).to have_title("Age range")
    expect(page).to have_content("Who you can teach")
    expect(page).to have_content("What age range are you qualified to teach?")
    expect(page).to have_content("From")
    expect(page).to have_content("To")
  end

  def then_i_see_the_has_work_history_form
    expect(page).to have_title("Your work history")
    expect(page).to have_content("Have you worked professionally as a teacher?")
    expect(page).to have_content("Yes")
    expect(page).to have_content("No")
  end

  def then_i_see_the_work_history_form
    expect(page).to have_title("Your work history")
    expect(page).to have_content("Your work history in education")
    expect(page).to have_content("Your current or most recent role")
  end

  def then_i_see_the_registration_number_form
    expect(page).to have_title("Registration number")
    expect(page).to have_content("What is your registration number?")
  end

  def then_i_see_the_upload_written_statement_form
    expect(page).to have_title("Upload a document")
    expect(page).to have_content("Upload your written statement")
  end

  def then_i_see_the_personal_information_summary
    expect(page).to have_content("Check your answers")
    expect(page).to have_content("Given names\tName")
    expect(page).to have_content("Family name\tName")
    expect(page).to have_content("Date of birth\t1 January 2000")
    expect(page).to have_content(
      "Legal name different to identity document?\tYes"
    )
    expect(page).to have_content("Alternative given names\tName")
    expect(page).to have_content("Alternative family name\tName")
    expect(page).to have_content("Name change document")
  end

  def then_i_see_completed_personal_information_section
    expect(page).to have_content("Enter your personal information\nCOMPLETED")
  end

  def then_i_see_completed_identity_document_section
    expect(page).to have_content("Upload your identity document\nCOMPLETED")
  end

  def then_i_see_the_qualifications_summary
    expect(page).to have_content("Check your answers")
    expect(page).to have_content("Qualification title\tTitle")
    expect(page).to have_content("Name of institution\tName")
    expect(page).to have_content("Country of institution\tCountry")
  end

  def then_i_see_completed_qualifications_section
    expect(page).to have_content("Add your teaching qualifications\nCOMPLETED")
  end

  def then_i_see_the_age_range_summary
    expect(page).to have_content("Check your answers")
    expect(page).to have_content("Minimum age\t7")
    expect(page).to have_content("Maximum age\t11")
  end

  def then_i_see_completed_age_range_section
    expect(page).to have_content("Enter the age range you can teach\nCOMPLETED")
  end

  def then_i_see_the_work_history_summary
    expect(page).to have_content("Work history")
    expect(page).to have_content(
      "Have you worked professionally as a teacher?\tYes"
    )
    expect(page).to have_content("Your current or most recent role")
    expect(page).to have_content("School name\tSchool name")
    expect(page).to have_content("City of institution\tCity")
    expect(page).to have_content("Country of institution\tCountry")
    expect(page).to have_content("Your job role\tJob")
    expect(page).to have_content("Contact email address\ttest@example.com")
    expect(page).to have_content("Role start date\tJanuary 2000")
  end

  def then_i_see_completed_work_history_section
    expect(page).to have_content("Add your work history\nCOMPLETED")
  end

  def then_i_see_the_registration_number_summary
    expect(page).to have_content("Registration number")
    expect(page).to have_content("Registration number\tABC")
  end

  def then_i_see_completed_registration_number_section
    expect(page).to have_content("Enter your registration number\nCOMPLETED")
  end

  def then_i_see_completed_written_statement_section
    expect(page).to have_content("Upload your written statement\nCOMPLETED")
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title("Check your answers")
    expect(page).to have_content(
      "Check your answers before submitting your application"
    )
    expect(page).to have_content("About you")
    expect(page).to have_content("Who you can teach")
    expect(page).to have_content("Your teaching qualification")
  end

  def and_i_see_check_your_work_history
    expect(page).to have_content("Your work history")
  end

  def and_i_see_check_proof_of_recognition
    expect(page).to have_content("Proof that you’re recognised as a teacher")
  end

  def then_i_see_the_submitted_application_page
    application_form = ApplicationForm.last

    expect(page).to have_current_path("/teacher/application_form")
    expect(page).to have_title("Apply for qualified teacher status (QTS)")
    expect(page).to have_content("Apply for qualified teacher status (QTS)")
    expect(page).to have_content("Application complete")
    expect(page).to have_content("Your reference number")
    expect(page).to have_content(application_form.reference)
  end

  def then_i_see_delete_confirmation_form
    expect(page).to have_title("Delete")
    expect(page).to have_content("Are you sure you want to delete")
  end
end
