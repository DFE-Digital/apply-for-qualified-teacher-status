require "rails_helper"

RSpec.describe "Teacher application", type: :system do
  it "allows making an application" do
    given_the_service_is_open
    given_the_service_is_startable
    given_the_service_allows_teacher_applications
    given_an_eligible_eligibility_check

    when_i_click_apply_for_qts
    then_i_see_the_sign_up_form

    when_i_fill_teacher_email_address
    and_i_click_sign_up
    then_i_receive_a_teacher_confirmation_email

    when_i_visit_the_teacher_confirmation_email
    then_i_see_the_new_application_page

    when_i_click_start_now
    then_i_see_the_active_application_page

    when_i_click_personal_information
    then_i_see_the_personal_information_form

    when_i_fill_in_personal_information
    and_i_click_continue
    then_i_see_completed_personal_information_section

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

  def when_i_click_submit
    click_button "Submit your application"
  end

  def and_i_click_continue
    click_button "Continue"
  end

  def when_i_click_personal_information
    click_link "Personal information"
  end

  def when_i_fill_in_personal_information
    fill_in "application-form-given-names-field", with: "Name"
    fill_in "application-form-family-name-field", with: "Name"
    fill_in "application_form_date_of_birth_3i", with: "1"
    fill_in "application_form_date_of_birth_2i", with: "1"
    fill_in "application_form_date_of_birth_1i", with: "2000"
  end

  def then_i_see_the_sign_up_form
    expect(page).to have_current_path("/teacher/sign_up")
    expect(page).to have_title("Sign up")
    expect(page).to have_content("Sign up")
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

    expect(page).to have_content("You have completed 0 of 2 sections.")

    expect(page).to have_content("About you")
    expect(page).to have_content("Personal information\nNOT STARTED")
    expect(page).to have_content("Identity documents\nNOT STARTED")

    expect(page).to have_content("Your work history")
    expect(page).to have_content("Work history\nNOT STARTED")

    expect(page).to have_content("Submit your application")
  end

  def then_i_see_the_personal_information_form
    expect(page).to have_title("Personal information")
    expect(page).to have_content("Personal information")
    expect(page).to have_content("Given names")
    expect(page).to have_content("Family name")
    expect(page).to have_content("Date of birth")
  end

  def then_i_see_completed_personal_information_section
    expect(page).to have_content("Personal information\nCOMPLETED")
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
