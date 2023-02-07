require "rails_helper"

RSpec.describe "Teacher application", type: :system do
  before do
    given_the_service_is_open
    given_the_service_allows_teacher_applications
  end

  it "allows making an application for a country with no checks" do
    given_an_eligible_eligibility_check_with_none_country_checks

    when_i_click_apply_for_qts
    and_i_sign_up
    then_i_see_the_teacher_application_page
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
    then_i_see_the_check_your_name_change_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_the_personal_information_summary

    when_i_click_continue
    then_i_see_completed_personal_information_section

    when_i_click_identification_document
    then_i_see_the_upload_identification_form

    when_i_fill_in_the_upload_identification_form
    and_i_click_continue
    then_i_see_the_check_your_identification_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_completed_identification_document_section

    when_i_click_qualifications
    then_i_see_the_qualifications_form

    when_i_fill_in_qualifications
    and_i_click_continue
    then_i_see_the_upload_certificate_form

    when_i_fill_in_the_upload_certificate_form
    and_i_click_continue
    then_i_see_the_check_your_certificate_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_the_upload_transcript_form

    when_i_fill_in_the_upload_transcript_form
    and_i_click_continue
    then_i_see_the_check_your_transcript_uploads

    when_i_choose_no
    and_i_click_continue

    when_i_choose_no
    and_i_click_continue
    then_i_see_the(:teacher_check_qualification_page)
    and_i_see_the_qualification_summary

    when_i_click_continue
    then_i_see_the_university_degree_form

    when_i_fill_in_qualifications
    and_i_click_continue
    then_i_see_the_upload_certificate_form

    when_i_fill_in_the_upload_certificate_form
    and_i_click_continue
    then_i_see_the_check_your_certificate_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_the_upload_transcript_form

    when_i_fill_in_the_upload_transcript_form
    and_i_click_continue
    then_i_see_the_check_your_transcript_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_the(:teacher_check_qualification_page)

    when_i_click_continue
    and_i_choose_no
    and_i_click_continue
    then_i_see_the(:teacher_check_qualifications_page)

    when_i_click_continue
    then_i_see_completed_qualifications_section

    when_i_click_age_range
    then_i_see_the_age_range_form

    when_i_fill_in_age_range
    and_i_click_continue
    then_i_see_completed_age_range_section

    when_i_click_subjects
    then_i_see_the_subjects_form

    when_i_fill_in_subjects
    and_i_click_continue
    then_i_see_completed_subjects_section

    when_i_click_work_history
    then_i_see_the_has_work_history_form

    when_i_fill_in_has_work_history
    and_i_click_continue
    then_i_see_the_work_history_form

    when_i_fill_in_work_history
    and_i_click_continue
    then_i_see_the(:teacher_check_work_history_page)
    and_i_see_the_work_history_summary

    when_i_click_continue
    and_i_choose_no
    and_i_click_continue
    then_i_see_completed_work_history_section

    when_i_click_check_your_answers
    then_i_see_the_check_your_answers_page
    and_i_see_check_your_work_history

    when_i_confirm_i_have_no_sanctions
    when_i_click_submit
    then_i_see_the(:submitted_application_page)
    and_i_see_the_submitted_application_information
    and_i_receive_an_application_email
  end

  it "allows making an application for a country with online checks" do
    given_an_eligible_eligibility_check_with_online_country_checks

    when_i_click_apply_for_qts
    and_i_sign_up
    then_i_see_the_teacher_application_page
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
    then_i_see_the_check_your_name_change_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_the_personal_information_summary

    when_i_click_continue
    then_i_see_completed_personal_information_section

    when_i_click_identification_document
    then_i_see_the_upload_identification_form

    when_i_fill_in_the_upload_identification_form
    and_i_click_continue
    then_i_see_the_check_your_identification_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_completed_identification_document_section

    when_i_click_qualifications
    then_i_see_the_qualifications_form

    when_i_fill_in_qualifications
    and_i_click_continue
    then_i_see_the_upload_certificate_form

    when_i_fill_in_the_upload_certificate_form
    and_i_click_continue
    then_i_see_the_check_your_certificate_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_the_upload_transcript_form

    when_i_fill_in_the_upload_transcript_form
    and_i_click_continue
    then_i_see_the_check_your_transcript_uploads

    when_i_choose_no
    and_i_click_continue

    when_i_choose_yes
    and_i_click_continue
    then_i_see_the(:teacher_check_qualification_page)
    and_i_see_the_qualification_summary

    when_i_click_continue
    and_i_choose_no
    and_i_click_continue
    then_i_see_completed_qualifications_section

    when_i_click_age_range
    then_i_see_the_age_range_form

    when_i_fill_in_age_range
    and_i_click_continue
    then_i_see_completed_age_range_section

    when_i_click_subjects
    then_i_see_the_subjects_form

    when_i_fill_in_subjects
    and_i_click_continue
    then_i_see_completed_subjects_section

    when_i_click_registration_number
    then_i_see_the_registration_number_form

    when_i_fill_in_registration_number
    and_i_click_continue
    then_i_see_completed_registration_number_section

    when_i_click_check_your_answers
    then_i_see_the_check_your_answers_page
    and_i_see_check_proof_of_recognition
    and_i_see_check_registration_number

    when_i_confirm_i_have_no_sanctions
    when_i_click_submit
    then_i_see_the(:submitted_application_page)
    and_i_see_the_submitted_application_information
    and_i_receive_an_application_email
  end

  it "allows making an application for a country with written checks" do
    given_an_eligible_eligibility_check_with_written_country_checks

    when_i_click_apply_for_qts
    and_i_sign_up
    then_i_see_the_teacher_application_page
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
    then_i_see_the_check_your_name_change_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_the_personal_information_summary

    when_i_click_continue
    then_i_see_completed_personal_information_section

    when_i_click_identification_document
    then_i_see_the_upload_identification_form

    when_i_fill_in_the_upload_identification_form
    and_i_click_continue
    then_i_see_the_check_your_identification_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_completed_identification_document_section

    when_i_click_qualifications
    then_i_see_the_qualifications_form

    when_i_fill_in_qualifications
    and_i_click_continue
    then_i_see_the_upload_certificate_form

    when_i_fill_in_the_upload_certificate_form
    and_i_click_continue
    then_i_see_the_check_your_certificate_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_the_upload_transcript_form

    when_i_fill_in_the_upload_transcript_form
    and_i_click_continue
    then_i_see_the_check_your_transcript_uploads

    when_i_choose_no
    and_i_click_continue

    when_i_choose_yes
    and_i_click_continue
    then_i_see_the(:teacher_check_qualification_page)
    and_i_see_the_qualification_summary

    when_i_click_continue
    and_i_choose_no
    and_i_click_continue
    then_i_see_completed_qualifications_section

    when_i_click_age_range
    then_i_see_the_age_range_form

    when_i_fill_in_age_range
    and_i_click_continue
    then_i_see_completed_age_range_section

    when_i_click_subjects
    then_i_see_the_subjects_form

    when_i_fill_in_subjects
    and_i_click_continue
    then_i_see_completed_subjects_section

    when_i_click_written_statement
    then_i_see_the_upload_written_statement_form

    when_i_fill_in_the_upload_written_statement_form
    and_i_click_continue
    then_i_see_the_check_your_written_statement_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_completed_written_statement_section

    when_i_click_check_your_answers
    then_i_see_the_check_your_answers_page
    and_i_see_check_proof_of_recognition

    when_i_confirm_i_have_no_sanctions
    when_i_click_submit
    then_i_see_the(:submitted_application_page)
    and_i_see_the_submitted_application_information
    and_i_receive_an_application_email
  end

  it "allows deleting work history" do
    given_an_eligible_eligibility_check_with_none_country_checks

    when_i_click_apply_for_qts
    and_i_sign_up
    then_i_see_the_teacher_application_page
    and_i_see_the_work_history_is_not_started

    when_i_click_work_history
    then_i_see_the_has_work_history_form

    when_i_fill_in_has_work_history
    and_i_click_continue
    then_i_see_the_work_history_form

    when_i_fill_in_work_history
    and_i_click_continue
    then_i_see_the(:teacher_check_work_history_page)
    and_i_see_the_work_history_summary

    when_i_click_continue
    and_i_choose_no
    and_i_click_continue
    then_i_see_the(:teacher_application_page)

    when_i_click_work_history
    then_i_see_the(:teacher_check_work_histories_page)

    when_i_click_delete
    then_i_see_delete_confirmation_form

    when_i_choose_yes
    and_i_click_continue
    then_i_see_the(:teacher_check_work_histories_page)
    and_i_see_the_empty_work_history_summary
  end

  it "allows delete qualifications" do
    given_an_eligible_eligibility_check_with_none_country_checks

    when_i_click_apply_for_qts
    and_i_sign_up
    then_i_see_the_teacher_application_page
    and_i_see_the_work_history_is_not_started

    when_i_click_qualifications
    then_i_see_the_qualifications_form

    when_i_fill_in_qualifications
    and_i_click_continue
    then_i_see_the_upload_certificate_form

    when_i_fill_in_the_upload_certificate_form
    and_i_click_continue
    then_i_see_the_check_your_certificate_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_the_upload_transcript_form

    when_i_fill_in_the_upload_transcript_form
    and_i_click_continue
    then_i_see_the_check_your_transcript_uploads

    when_i_choose_no
    and_i_click_continue

    when_i_choose_yes
    and_i_click_continue
    then_i_see_the(:teacher_check_qualification_page)
    and_i_see_the_qualification_summary

    when_i_click_continue
    and_i_choose_yes
    and_i_click_continue
    then_i_see_the_degree_qualifications_form

    when_i_fill_in_qualifications
    and_i_click_continue
    then_i_see_the_upload_degree_certificate_form

    when_i_fill_in_the_upload_certificate_form
    and_i_click_continue
    then_i_see_the_check_your_certificate_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_the_upload_degree_transcript_form

    when_i_fill_in_the_upload_transcript_form
    and_i_click_continue
    then_i_see_the_check_your_transcript_uploads

    when_i_choose_no
    and_i_click_continue
    then_i_see_the(:teacher_check_qualification_page)

    when_i_click_continue
    and_i_choose_no
    and_i_click_continue
    then_i_see_the(:teacher_check_qualifications_page)

    when_i_click_delete
    then_i_see_delete_confirmation_form

    when_i_choose_yes
    and_i_click_continue
    then_i_see_the(:teacher_check_qualifications_page)
  end

  it "allows skipping name change document" do
    given_an_eligible_eligibility_check_with_none_country_checks

    when_i_click_apply_for_qts
    and_i_sign_up
    then_i_see_the_teacher_application_page
    and_i_see_the_work_history_is_not_started

    when_i_click_personal_information
    then_i_see_the_name_and_date_of_birth_form

    when_i_fill_in_the_name_and_date_of_birth_form
    and_i_click_continue
    then_i_see_the_alternative_name_form

    when_i_choose_no
    and_i_click_continue
    then_i_see_the_personal_information_summary_without_name_change
  end

  it "allows starting an application form without a session" do
    when_i_visit_the(:teacher_sign_up_page)
    and_i_sign_up
    then_i_see_the(:teacher_new_application_page)
  end

  private

  def when_i_click_apply_for_qts
    eligible_page.apply_button.click
  end

  def when_i_click_start_now
    click_button "Start now"
  end

  def when_i_click_check_your_answers
    teacher_application_page.check_answers.click
  end

  def when_i_click_submit
    check_your_answers_page.submission_declaration.form.submit_button.click
  end

  alias_method :and_i_click_submit, :when_i_click_submit

  def when_i_click_continue
    click_link "Continue"
  end

  def when_i_click_remove
    click_link "Remove"
  end

  def when_i_click_personal_information
    teacher_application_page.task_list.click_item(
      "Enter your personal information",
    )
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

  def when_i_click_identification_document
    click_link "Upload your identity document"
  end

  def when_i_fill_in_the_upload_identification_form
    teacher_upload_document_page.form.original_attachment.attach_file Rails.root.join(
      file_fixture("upload.pdf"),
    )
  end

  def when_i_click_qualifications
    teacher_application_page.qualifications_task_item.click
  end

  def when_i_fill_in_qualifications
    qualifications_form_page.form.title.fill_in with: "Title"
    qualifications_form_page.form.institution_name.fill_in with:
      "Institution Name"
    qualifications_form_page.form.institution_country.fill_in with:
      CountryName.from_country(application_form.country)
    qualifications_form_page.form.start_date_month.fill_in with: "1"
    qualifications_form_page.form.start_date_year.fill_in with: "2000"
    qualifications_form_page.form.complete_date_month.fill_in with: "1"
    qualifications_form_page.form.complete_date_year.fill_in with: "2003"
    qualifications_form_page.form.certificate_date_month.fill_in with: "1"
    qualifications_form_page.form.certificate_date_year.fill_in with: "2004"
  end

  def when_i_fill_in_the_upload_certificate_form
    teacher_upload_document_page.form.original_attachment.attach_file Rails.root.join(
      file_fixture("upload.pdf"),
    )
    teacher_upload_document_page.form.written_in_english_items.first.choose
  end

  def when_i_fill_in_the_upload_transcript_form
    teacher_upload_document_page.form.original_attachment.attach_file Rails.root.join(
      file_fixture("upload.pdf"),
    )
    teacher_upload_document_page.form.written_in_english_items.first.choose
  end

  def when_i_click_age_range
    click_link "Enter the age range you can teach"
  end

  def when_i_fill_in_age_range
    fill_in "teacher-interface-age-range-form-minimum-field", with: "7"
    fill_in "teacher-interface-age-range-form-maximum-field", with: "11"
  end

  def when_i_click_subjects
    teacher_application_page.task_list.click_item(
      "Enter the subjects you can teach",
    )
  end

  def when_i_fill_in_subjects
    fill_in "teacher-interface-subjects-form-subject-1-field", with: "Subject1"
    fill_in "teacher-interface-subjects-form-subject-2-field", with: "Subject2"
  end

  def when_i_click_work_history
    teacher_application_page.task_list.click_item("Add your work history")
  end

  def when_i_fill_in_has_work_history
    choose "Yes", visible: false
  end

  def when_i_fill_in_work_history
    fill_in "teacher-interface-work-history-form-school-name-field",
            with: "School name"
    fill_in "teacher-interface-work-history-form-city-field", with: "City"
    fill_in "teacher-interface-work-history-form-country-location-field",
            with: "France"
    fill_in "teacher-interface-work-history-form-job-field", with: "Job"
    fill_in "teacher-interface-work-history-form-contact-name-field",
            with: "First Last"
    fill_in "teacher-interface-work-history-form-contact-email-field",
            with: "test@example.com"
    fill_in "teacher_interface_work_history_form_start_date_2i", with: "1"
    fill_in "teacher_interface_work_history_form_start_date_1i", with: "2000"
    choose "Yes", visible: false
  end

  def when_i_click_registration_number
    teacher_application_page.task_list.click_item(
      "Enter your registration number",
    )
  end

  def when_i_fill_in_registration_number
    fill_in "teacher-interface-registration-number-form-registration-number-field",
            with: "ABC"
  end

  def when_i_click_written_statement
    teacher_application_page.task_list.click_item(
      "Upload your written statement",
    )
  end

  def when_i_click_delete
    click_link "Delete"
  end

  def when_i_fill_in_the_upload_written_statement_form
    attach_file "teacher-interface-upload-form-original-attachment-field",
                Rails.root.join(file_fixture("upload.pdf"))
    teacher_upload_document_page.form.written_in_english_items.first.choose
  end

  def then_i_see_the_teacher_application_page
    expect(teacher_application_page).to have_current_path(
      "/teacher/application",
    )
    expect(teacher_application_page.heading.text).to eq(
      "Apply for qualified teacher status (QTS)",
    )

    expect(teacher_application_page).to have_content("About you")
    expect(teacher_application_page).to have_content(
      "Enter your personal information\nNOT STARTED",
    )
    expect(teacher_application_page).to have_content(
      "Upload your identity document\nNOT STARTED",
    )

    expect(teacher_application_page).to have_content("Your qualifications")
    expect(teacher_application_page).to have_content(
      "Enter the age range you can teach\nNOT STARTED",
    )

    expect(teacher_application_page).not_to have_content("Check your answers")
  end

  def and_i_see_the_work_history_is_not_started
    expect(teacher_application_page.app_task_list).to have_content(
      "Your work history",
    )

    expect(teacher_application_page.app_task_list).to have_content(
      "Add your work history\nNOT STARTED",
    )
  end

  def and_i_see_the_written_statement_is_not_started
    expect(teacher_application_page.app_task_list).to have_content(
      "Proof that you’re recognised as a teacher",
    )
    expect(teacher_application_page.app_task_list).to have_content(
      "Upload your written statement\nNOT STARTED",
    )
  end

  def and_i_see_the_registration_number_is_not_started
    expect(teacher_application_page.app_task_list).to have_content(
      "Proof that you’re recognised as a teacher",
    )
    expect(teacher_application_page.app_task_list).to have_content(
      "Enter your registration number\nNOT STARTED",
    )
  end

  def then_i_see_the_name_and_date_of_birth_form
    expect(name_and_date_of_birth_page).to have_title("About you")
    expect(name_and_date_of_birth_page.heading.text).to eq(
      "Personal information",
    )
    expect(name_and_date_of_birth_page.grid).to have_content("Given names")
    expect(name_and_date_of_birth_page.grid).to have_content("Family name")
    expect(name_and_date_of_birth_page.grid).to have_content("Date of birth")
  end

  def and_i_receive_an_application_email
    message = ActionMailer::Base.deliveries.last
    expect(message).to_not be_nil

    expect(message.subject).to eq(
      "We’ve received your application for qualified teacher status (QTS)",
    )
    expect(message.to).to include("test@example.com")
  end

  def then_i_see_the_alternative_name_form
    expect(alternative_name_page).to have_title("About you")
    expect(alternative_name_page.heading.text).to eq(
      "Does your name appear differently on your ID documents or qualifications?",
    )
    expect(alternative_name_page.grid).to have_content(
      "Yes – I’ll upload another document to prove this",
    )
    expect(alternative_name_page.grid).to have_content("No")
  end

  def then_i_see_the_upload_name_change_form
    expect(teacher_upload_document_page).to have_title("Upload a document")
    expect(teacher_upload_document_page.heading.text).to eq(
      "Upload proof of your change of name",
    )
  end

  def then_i_see_the_upload_identification_form
    expect(check_your_uploads_page).to have_title("Upload a document")
    expect(check_your_uploads_page.heading.text).to eq(
      "Upload a valid identification document",
    )
  end

  def then_i_see_the_check_your_identification_uploads
    expect(check_your_uploads_page).to have_title("Check your uploaded files")
    expect(check_your_uploads_page.heading.text).to eq(
      "Check your uploaded files – identity document",
    )
    expect(check_your_uploads_page.summary_list_row).to have_content(
      "File 1\tupload.pdf (opens in a new tab)\tDelete",
    )
  end

  def then_i_see_the_check_your_name_change_uploads
    expect(check_your_uploads_page).to have_title("Check your uploaded files")
    expect(check_your_uploads_page.heading.text).to eq(
      "Check your uploaded files – name change document",
    )
    expect(check_your_uploads_page.summary_list_row).to have_content(
      "File 1\tupload.pdf (opens in a new tab)\tDelete",
    )
  end

  def then_i_see_the_check_your_certificate_uploads
    expect(check_your_uploads_page).to have_title("Check your uploaded files")
    expect(check_your_uploads_page.heading.text).to eq(
      "Check your uploaded files – certificate document",
    )
    expect(check_your_uploads_page.summary_list_row).to have_content(
      "File 1\tupload.pdf (opens in a new tab)\tDelete",
    )
  end

  def then_i_see_the_check_your_transcript_uploads
    expect(check_your_uploads_page).to have_title("Check your uploaded files")
    expect(check_your_uploads_page.heading.text).to eq(
      "Check your uploaded files – transcript document",
    )
    expect(check_your_uploads_page.summary_list_row).to have_content(
      "File 1\tupload.pdf (opens in a new tab)\tDelete",
    )
  end

  def then_i_see_the_check_your_written_statement_uploads
    expect(check_your_uploads_page).to have_title("Check your uploaded files")
    expect(check_your_uploads_page.heading.text).to eq(
      "Check your uploaded files – written statement document",
    )
    expect(check_your_uploads_page.summary_list_row).to have_content(
      "File 1\tupload.pdf (opens in a new tab)\tDelete",
    )
  end

  def then_i_see_the_qualifications_form
    expect(qualifications_form_page).to have_title("Your qualifications")
    expect(qualifications_form_page.heading.text).to eq(
      "Your teaching qualification",
    )
    expect(qualifications_form_page.body).to have_content(
      "This is the qualification that led to you being recognised as a teacher.",
    )
    expect(qualifications_form_page.qualifications_information).to have_content(
      "Qualifications information",
    )
  end

  def then_i_see_the_university_degree_form
    expect(qualifications_form_page).to have_title("Your qualifications")
    expect(qualifications_form_page.heading.text).to eq("University degree")
    expect(qualifications_form_page.body).to have_content(
      "Tell us about your university degree qualification.",
    )
  end

  def then_i_see_the_degree_qualifications_form
    expect(qualifications_form_page).to have_title("Your qualifications")
    expect(qualifications_form_page.heading.text).to eq("University degree")
    expect(qualifications_form_page.body).to have_content(
      "Tell us about your university degree qualification.",
    )
  end

  def then_i_see_the_upload_certificate_form
    expect(teacher_upload_document_page).to have_title("Upload a document")
    expect(teacher_upload_document_page.heading.text).to eq(
      "Upload your Institution Name certificate",
    )
  end

  def then_i_see_the_upload_degree_certificate_form
    expect(teacher_upload_document_page).to have_title("Upload a document")
    expect(teacher_upload_document_page.heading.text).to eq(
      "Upload your Institution Name certificate",
    )
  end

  def then_i_see_the_upload_transcript_form
    expect(teacher_upload_document_page).to have_title("Upload a document")
    expect(teacher_upload_document_page.heading.text).to eq(
      "Upload your Institution Name transcript",
    )
  end

  def then_i_see_the_upload_degree_transcript_form
    expect(teacher_upload_document_page).to have_title("Upload a document")
    expect(teacher_upload_document_page.heading.text).to eq(
      "Upload your Institution Name transcript",
    )
  end

  def then_i_see_the_age_range_form
    expect(age_range_form).to have_title("Enter the age range you can teach")
    expect(age_range_form.heading.text).to eq(
      "What age range are you qualified to teach?",
    )
    expect(age_range_form.grid).to have_content("From")
    expect(age_range_form.grid).to have_content("To")
  end

  def then_i_see_the_subjects_form
    expect(subjects_form_page).to have_title("Enter the subjects you can teach")
    expect(subjects_form_page.heading.text).to eq(
      "What subjects are you qualified to teach?",
    )
  end

  def then_i_see_the_two_subjects_form
    expect(subjects_form_page).to have_title("Enter the subjects you can teach")
    expect(subjects_form_page.heading.text).to eq(
      "What subjects are you qualified to teach?",
    )
    expect(subjects_form_page).to have_content("Subject")
    expect(subjects_form_page).to have_content("Remove")
  end

  def then_i_see_the_has_work_history_form
    expect(work_history_form_page).to have_title("Your work history")
    expect(work_history_form_page.heading.text).to eq(
      "Have you worked professionally as a teacher?",
    )
    expect(work_history_form_page.grid).to have_content("Yes")
    expect(work_history_form_page.grid).to have_content("No")
  end

  def then_i_see_the_work_history_form
    expect(work_history_form_page).to have_title("Your work history")
    expect(work_history_form_page).to have_content(
      "Your work history in education",
    )
    expect(work_history_form_page).to have_content(
      "Your current or most recent role",
    )
  end

  def then_i_see_the_registration_number_form
    expect(registration_number_form).to have_title(
      "Enter your registration number",
    )
    expect(registration_number_form.heading.text).to eq(
      "What is your registration number?",
    )
    expect(registration_number_form).to have_content("Status information")
    expect(registration_number_form).to have_content("Sanction information")
  end

  def then_i_see_the_upload_written_statement_form
    expect(teacher_upload_document_page).to have_title("Upload a document")
    expect(teacher_upload_document_page.heading.text).to eq(
      "Upload your written statement",
    )
    expect(teacher_upload_document_page).to have_content("Status information")
    expect(teacher_upload_document_page).to have_content("Sanction information")
  end

  def then_i_see_the_personal_information_summary
    expect(personal_information_summary_page).to have_content(
      "Check your answers",
    )
    expect(personal_information_summary_page).to have_content(
      "Given names\tName",
    )
    expect(personal_information_summary_page).to have_content(
      "Family name\tName",
    )
    expect(personal_information_summary_page).to have_content(
      "Date of birth\t1 January 2000",
    )
    expect(personal_information_summary_page).to have_content(
      "Name appears differently on your ID documents or qualifications?\tYes",
    )
    expect(personal_information_summary_page).to have_content(
      "Alternative given names\tName",
    )
    expect(personal_information_summary_page).to have_content(
      "Alternative family name\tName",
    )
    expect(personal_information_summary_page).to have_content(
      "Name change document",
    )
  end

  def then_i_see_the_personal_information_summary_without_name_change
    expect(personal_information_summary_page.heading.text).to eq(
      "Check your answers",
    )
    expect(personal_information_summary_page.summary_card).to have_content(
      "Given names\tName",
    )
    expect(personal_information_summary_page.summary_card).to have_content(
      "Family name\tName",
    )
    expect(personal_information_summary_page.summary_card).to have_content(
      "Date of birth\t1 January 2000",
    )
    expect(personal_information_summary_page.summary_card).to have_content(
      "Name appears differently on your ID documents or qualifications?\tNo",
    )
  end

  def then_i_see_completed_personal_information_section
    expect(teacher_application_page.app_task_list).to have_content(
      "Enter your personal information\nCOMPLETED",
    )
  end

  def then_i_see_completed_identification_document_section
    expect(teacher_application_page.app_task_list).to have_content(
      "Upload your identity document\nCOMPLETED",
    )
  end

  def and_i_see_the_qualification_summary
    expect(teacher_check_qualification_page.summary_list).to have_content(
      "Qualification title\tTitle",
    )
    expect(teacher_check_qualification_page.summary_list).to have_content(
      "Name of institution\tInstitution Name",
    )
    expect(teacher_check_qualification_page.summary_list).to have_content(
      "Country of institution\t#{CountryName.from_country(application_form.country)}",
    )
  end

  def then_i_see_completed_qualifications_section
    expect(teacher_application_page.app_task_list).to have_content(
      "Add your teaching qualifications\nCOMPLETED",
    )
  end

  def then_i_see_completed_age_range_section
    expect(teacher_application_page.app_task_list).to have_content(
      "Enter the age range you can teach\nCOMPLETED",
    )
  end

  def then_i_see_completed_subjects_section
    expect(teacher_application_page.app_task_list).to have_content(
      "Enter the subjects you can teach\nCOMPLETED",
    )
  end

  def and_i_see_the_work_history_summary
    expect(teacher_check_work_history_page.summary_list).to have_content(
      "School name\tSchool name",
    )
    expect(teacher_check_work_history_page.summary_list).to have_content(
      "City of institution\tCity",
    )
    expect(teacher_check_work_history_page.summary_list).to have_content(
      "Country of institution\tFrance",
    )
    expect(teacher_check_work_history_page.summary_list).to have_content(
      "Your job role\tJob",
    )
    expect(teacher_check_work_history_page.summary_list).to have_content(
      "Contact email address\ttest@example.com",
    )
    expect(teacher_check_work_history_page.summary_list).to have_content(
      "Role start date\tJanuary 2000",
    )
  end

  def and_i_see_the_empty_work_history_summary
    expect(teacher_check_work_histories_page.heading.text).to eq(
      "Check your answers",
    )
    expect(
      teacher_check_work_histories_page.summary_list_cards.first,
    ).to have_content("Have you worked professionally as a teacher?\tYes")
  end

  def then_i_see_completed_work_history_section
    expect(teacher_application_page.app_task_list).to have_content(
      "Add your work history\nCOMPLETED",
    )
  end

  def then_i_see_completed_registration_number_section
    expect(teacher_application_page.app_task_list).to have_content(
      "Enter your registration number\nCOMPLETED",
    )
  end

  def then_i_see_completed_written_statement_section
    expect(teacher_application_page.app_task_list).to have_content(
      "Upload your written statement\nCOMPLETED",
    )
  end

  def then_i_see_the_check_your_answers_page
    expect(check_your_answers_page).to have_title("Check your answers")
    expect(check_your_answers_page.heading.text).to eq(
      "Check your answers before submitting your application",
    )

    expect(check_your_answers_page.about_you).to be_visible
    expect(check_your_answers_page.who_you_can_teach).to be_visible

    qualification_summary_list =
      check_your_answers_page.who_you_can_teach.qualification_summary_list
    expect(qualification_summary_list).to have_content("Qualification title")

    minimum_age_row =
      check_your_answers_page
        .who_you_can_teach
        .age_range_summary_list
        .rows
        .first
    expect(minimum_age_row.key.text).to eq("Minimum age")
    expect(minimum_age_row.value.text).to eq("7")

    maximum_age_row =
      check_your_answers_page
        .who_you_can_teach
        .age_range_summary_list
        .rows
        .second
    expect(maximum_age_row.key.text).to eq("Maximum age")
    expect(maximum_age_row.value.text).to eq("11")

    subject_row =
      check_your_answers_page.who_you_can_teach.subjects_summary_list.rows.first
    expect(subject_row.key.text).to eq("Subjects")
    expect(subject_row.value.text).to eq("Subject1\nSubject2")
  end

  def and_i_see_check_your_work_history
    expect(check_your_answers_page.work_history).to be_visible
  end

  def and_i_see_check_proof_of_recognition
    expect(check_your_answers_page.proof_of_recognition).to be_visible
  end

  def and_i_see_check_registration_number
    expect(
      check_your_answers_page.proof_of_recognition.registration_number_summary_list,
    ).to be_visible
  end

  def and_i_see_the_submitted_application_information
    expect(submitted_application_page.panel.title.text).to eq(
      "Application complete",
    )
    expect(submitted_application_page.panel.body.text).to eq(
      "Your reference number\n#{application_form.reference}",
    )
  end

  def then_i_see_delete_confirmation_form
    expect(teacher_delete_form_page).to have_title("Delete")
    expect(teacher_delete_form_page.heading).to have_content(
      "Are you sure you want to delete",
    )
  end

  def when_i_confirm_i_have_no_sanctions
    check_your_answers_page
      .submission_declaration
      .form
      .confirm_no_sanctions
      .click
  end

  def application_form
    @application_form ||= ApplicationForm.last
  end
end
