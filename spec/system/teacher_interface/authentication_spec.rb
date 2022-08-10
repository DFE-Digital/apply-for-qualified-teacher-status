require "rails_helper"

RSpec.describe "Teacher authentication", type: :system do
  before { given_the_service_is_open }

  it "allows signing up and signing in" do
    given_countries_exist

    when_i_visit_the_sign_up_page
    then_i_see_the_sign_up_form

    when_i_fill_teacher_email_address
    and_i_click_continue
    then_i_see_the_check_your_email_page
    and_i_receive_a_teacher_confirmation_email

    when_i_visit_the_teacher_confirmation_email
    then_i_see_successful_confirmation

    given_i_clear_my_session

    when_i_visit_the_sign_in_page
    then_i_see_the_sign_in_form

    when_i_choose_yes_sign_in
    and_i_fill_teacher_email_address
    and_i_click_continue
    then_i_see_the_check_your_email_page
    and_i_receive_a_magic_link_email

    when_i_visit_the_magic_link_email
    then_i_see_the_new_application_form

    given_i_clear_my_session

    when_i_visit_the_sign_up_page
    then_i_see_the_sign_up_form

    when_i_fill_teacher_email_address
    and_i_click_continue
    then_i_see_the_check_your_email_page
    and_i_receive_a_magic_link_email

    when_i_visit_the_magic_link_email
    then_i_see_the_new_application_form

    when_i_select_a_country
    and_i_click_continue

    when_i_click_sign_out
    then_i_see_the_signed_out_page
  end

  it "sign up with invalid email address" do
    when_i_visit_the_sign_up_page
    and_i_click_continue
    then_i_see_the_blank_email_address_message
  end

  it "sign in when unconfirmed" do
    when_i_visit_the_sign_in_page
    then_i_see_the_sign_in_form

    when_i_choose_yes_sign_in
    and_i_fill_teacher_email_address
    and_i_click_continue
    then_i_see_the_sign_in_form
  end

  it "sign in invalid email" do
    when_i_visit_the_sign_up_page
    then_i_see_the_sign_up_form

    when_i_fill_teacher_email_address
    and_i_click_continue
    then_i_see_the_check_your_email_page
    and_i_receive_a_teacher_confirmation_email

    when_i_visit_the_sign_in_page
    then_i_see_the_sign_in_form

    when_i_choose_yes_sign_in
    and_i_fill_teacher_email_address
    and_i_click_continue
    then_i_see_the_check_your_email_page
    and_i_receive_a_teacher_confirmation_email
  end

  private

  def given_countries_exist
    create(:country, :with_national_region, code: "GB-SCT")
  end

  def given_i_clear_my_session
    page.driver.clear_cookies
    ActionMailer::Base.deliveries = []
  end

  def when_i_visit_the_sign_up_page
    visit new_teacher_registration_path
  end

  def when_i_visit_the_sign_in_page
    visit new_teacher_session_path
  end

  def when_i_visit_the_magic_link_email
    message = ActionMailer::Base.deliveries.last
    uri = URI.parse(URI.extract(message.body.to_s).second)
    expect(uri.path).to eq("/teacher/magic_link")
    expect(uri.query).to include("token")
    visit "#{uri.path}?#{uri.query}"
  end

  def when_i_choose_yes_sign_in
    choose "Yes, sign in", visible: false
  end

  def when_i_select_a_country
    fill_in "teacher-interface-country-region-form-location-field",
            with: "Scotland"
  end

  def when_i_click_sign_out
    click_button "Save and sign out"
  end

  def then_i_see_the_sign_up_form
    expect(page).to have_current_path("/teacher/sign_up")
    expect(page).to have_title("Create an account")
    expect(page).to have_content("Create an account")
  end

  def then_i_see_the_check_your_email_page
    expect(page).to have_title("Check your email")
    expect(page).to have_content("Check your email")
  end

  def then_i_see_successful_confirmation
    expect(page).to have_content(
      "In which country are you currently recognised as a teacher?"
    )
  end

  def then_i_see_the_new_application_form
    expect(page).to have_content(
      "In which country are you currently recognised as a teacher?"
    )
  end

  def then_i_see_the_blank_email_address_message
    expect(page).to have_content("Enter your email address")
  end

  def then_i_see_the_signed_out_page
    expect(page).to have_content(
      "We’ve signed you out of the Apply for qualified teacher status (QTS) service."
    )
    expect(page).to have_content(
      "We’ve saved the information you’ve added to your application so far."
    )
  end

  alias_method :and_i_fill_teacher_email_address,
               :when_i_fill_teacher_email_address

  def and_i_receive_a_magic_link_email
    message = ActionMailer::Base.deliveries.last
    expect(message).to_not be_nil

    expect(message.subject).to eq("Here's your magic login link")
    expect(message.to).to include("test@example.com")
  end

  def and_i_click_continue
    click_button "Continue", visible: false
  end
end
