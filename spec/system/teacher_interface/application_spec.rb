require "rails_helper"

RSpec.describe "Teacher application", type: :system do
  it "allows making an application" do
    given_the_service_is_open
    given_the_service_is_startable
    given_the_service_allows_teacher_applications
    given_an_eligible_eligibility_check

    when_i_click_apply_for_qts
    then_i_see_the_sign_in_form
    and_i_sign_up
    then_i_see_the_new_application_page

    when_i_click_start_now
    then_i_see_the_active_application_page

    when_i_click_personal_information
    then_i_see_the_name_and_date_of_birth_form

    when_i_fill_in_the_name_and_date_of_birth_form
    and_i_click_continue
    then_i_see_the_alternative_name_form

    when_i_fill_in_the_alternative_name_form
    and_i_click_continue
    then_i_see_the_personal_information_summary

    when_i_click_continue
    then_i_see_completed_personal_information_section

    when_i_click_age_range
    then_i_see_the_age_range_form

    when_i_fill_in_age_range
    and_i_click_continue
    then_i_see_the_age_range_summary

    when_i_click_continue
    then_i_see_completed_age_range_section

    when_i_click_work_history
    then_i_see_the_work_history_form

    when_i_fill_in_work_history
    and_i_click_continue
    then_i_see_the_work_history_summary

    when_i_choose_no
    and_i_click_continue
    then_i_see_completed_work_history_section

    when_i_click_check_your_answers
    then_i_see_the_check_your_answers_page

    when_i_click_submit
    then_i_see_the_submitted_application_page
  end

  private

  def given_the_service_allows_teacher_applications
    FeatureFlag.activate(:teacher_applications)
  end

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
    click_link "Enter personal information"
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
    choose "Yes – I'll upload another document to prove this", visible: false
    fill_in "teacher-interface-alternative-name-form-alternative-given-names-field",
            with: "Name"
    fill_in "teacher-interface-alternative-name-form-alternative-family-name-field",
            with: "Name"
  end

  def when_i_click_age_range
    click_link "Enter age range"
  end

  def when_i_fill_in_age_range
    fill_in "teacher-interface-age-range-form-age-range-min-field", with: "7"
    fill_in "teacher-interface-age-range-form-age-range-max-field", with: "11"
  end

  def when_i_click_work_history
    click_link "Add work history"
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

  def when_i_choose_no
    choose "No", visible: false
  end

  def then_i_see_the_new_application_page
    expect(page).to have_current_path("/teacher/applications/new")
    expect(page).to have_title("Start your application")
    expect(page).to have_content("Start your application")
  end

  def then_i_see_the_active_application_page
    expect(page).to have_current_path(
      teacher_interface_application_form_path(ApplicationForm.last)
    )
    expect(page).to have_title("Apply for qualified teacher status (QTS)")
    expect(page).to have_content("Apply for qualified teacher status (QTS)")

    expect(page).to have_content("You have completed 0 of 3 sections.")

    expect(page).to have_content("About you")
    expect(page).to have_content("Enter personal information\nNOT STARTED")

    expect(page).to have_content("Your qualifications")
    expect(page).to have_content("Enter age range\nNOT STARTED")

    expect(page).to have_content("Your work history")
    expect(page).to have_content("Add work history\nNOT STARTED")

    expect(page).to have_content("Check your answers")
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
      "Yes – I'll upload another document to prove this"
    )
    expect(page).to have_content("No")
  end

  def then_i_see_the_age_range_form
    expect(page).to have_title("Age range")
    expect(page).to have_content("Who you can teach")
    expect(page).to have_content("What age range are you qualified to teach?")
    expect(page).to have_content("From")
    expect(page).to have_content("To")
  end

  def then_i_see_the_work_history_form
    expect(page).to have_title("Your work history in education")
    expect(page).to have_content("Your work history in education")
    expect(page).to have_content("Your current or most recent role")
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
    expect(page).to have_content("Enter personal information\nCOMPLETED")
  end

  def then_i_see_the_age_range_summary
    expect(page).to have_content("Check your answers")
    expect(page).to have_content("Minimum age\t7")
    expect(page).to have_content("Maximum age\t11")
  end

  def then_i_see_completed_age_range_section
    expect(page).to have_content("Enter age range\nCOMPLETED")
  end

  def then_i_see_the_work_history_summary
    expect(page).to have_content("Your current or most recent role")
    expect(page).to have_content("School name\tSchool name")
    expect(page).to have_content("City of institution\tCity")
    expect(page).to have_content("Country of institution\tCountry")
    expect(page).to have_content("Your job role\tJob")
    expect(page).to have_content("Contact email address\ttest@example.com")
    expect(page).to have_content("Role start date\tJanuary 2000")
  end

  def then_i_see_completed_work_history_section
    expect(page).to have_content("Add work history\nCOMPLETED")
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title("Check your answers")
    expect(page).to have_content(
      "Check your answers before submitting your application"
    )
    expect(page).to have_content("About you")
    expect(page).to have_content("Who you can teach")
    expect(page).to have_content("Your work history")
  end

  def then_i_see_the_submitted_application_page
    application_form = ApplicationForm.last

    expect(page).to have_current_path(
      teacher_interface_application_form_path(application_form)
    )
    expect(page).to have_title("Apply for qualified teacher status (QTS)")
    expect(page).to have_content("Apply for qualified teacher status (QTS)")
    expect(page).to have_content("Application complete")
    expect(page).to have_content("Your reference number")
    expect(page).to have_content(application_form.reference)
  end
end
