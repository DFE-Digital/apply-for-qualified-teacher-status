require "rails_helper"

RSpec.describe "Teacher authentication", type: :system do
  before { given_the_service_is_open }

  it "allows signing up and signing in" do
    given_countries_exist

    when_i_visit_the_sign_up_page
    then_i_see_the_sign_up_form
    when_i_fill_create_teacher_email_address
    and_i_click_continue
    then_i_see_the_check_your_email_page
    and_i_receive_a_teacher_confirmation_email

    when_i_visit_the_teacher_confirmation_email
    then_i_see_successful_confirmation

    given_i_clear_my_session

    when_i_visit_the_sign_in_page
    then_i_see_the_sign_in_form

    when_i_choose_yes_sign_in
    and_i_fill_sign_in_teacher_email_address
    and_i_click_continue
    then_i_see_the_check_your_email_page
    and_i_receive_a_magic_link_email

    when_i_visit_the_magic_link_email
    then_i_see_the_new_application_form

    given_i_clear_my_session

    when_i_visit_the_sign_up_page
    then_i_see_the_sign_up_form

    when_i_fill_create_teacher_email_address
    and_i_click_continue
    then_i_see_the_check_your_email_page
    and_i_receive_a_magic_link_email

    when_i_visit_the_magic_link_email
    then_i_see_the_new_application_form

    when_i_select_a_country
    and_i_click_continue

    when_i_click_save_and_sign_out
    then_i_see_the_signed_out_page
  end

  it "sign out with navigation link" do
    when_i_visit_the_sign_up_page

    when_i_fill_create_teacher_email_address
    and_i_click_continue
    then_i_see_the_check_your_email_page
    and_i_receive_a_teacher_confirmation_email

    when_i_visit_the_teacher_confirmation_email

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
    and_i_fill_sign_in_teacher_email_address
    and_i_click_continue
    then_i_see_the_check_your_email_page
  end

  it "sign in invalid email" do
    when_i_visit_the_sign_up_page
    then_i_see_the_sign_up_form

    when_i_fill_create_teacher_email_address
    and_i_click_continue
    then_i_see_the_check_your_email_page
    and_i_receive_a_teacher_confirmation_email

    when_i_visit_the_sign_in_page
    then_i_see_the_sign_in_form

    when_i_choose_yes_sign_in
    and_i_fill_sign_in_teacher_email_address
    and_i_click_continue
    then_i_see_the_check_your_email_page
    and_i_receive_a_teacher_confirmation_email
  end

  it "confirming email twice" do
    when_i_visit_the_sign_up_page
    then_i_see_the_sign_up_form

    when_i_fill_create_teacher_email_address
    and_i_click_continue
    then_i_see_the_check_your_email_page
    and_i_receive_a_teacher_confirmation_email

    when_i_visit_the_teacher_confirmation_email
    then_i_see_successful_confirmation

    given_i_clear_my_session

    when_i_visit_the_teacher_confirmation_email
    then_i_see_the_sign_in_form
    and_i_see_already_confirmed_message
  end

  it "sign in with same token" do
    given_countries_exist

    when_i_visit_the_sign_up_page
    then_i_see_the_sign_up_form
    and_i_sign_up

    given_i_clear_my_session

    when_i_visit_the_sign_in_page
    then_i_see_the_sign_in_form

    when_i_choose_yes_sign_in
    and_i_fill_sign_in_teacher_email_address
    and_i_click_continue
    then_i_see_the_check_your_email_page
    and_i_receive_a_magic_link_email

    when_i_visit_the_magic_link_email
    then_i_see_the_new_application_form

    given_i_clear_my_session

    when_i_visit_the_magic_link_email
    then_i_see_the_sign_in_form
  end

  private

  def given_countries_exist
    create(:country, :with_national_region, code: "GB-SCT")
  end

  def given_i_clear_my_session
    page.driver.clear_cookies
  end

  def when_i_visit_the_sign_up_page
    when_i_visit_the(:teacher_sign_up_page)
  end

  def when_i_visit_the_sign_in_page
    teacher_sign_in_page.load
  end

  def when_i_visit_the_magic_link_email
    message = ActionMailer::Base.deliveries.last
    uri = URI.parse(URI.extract(message.body.encoded).first)
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
    click_link "Sign out"
  end

  def when_i_click_save_and_sign_out
    click_link "Save and sign out"
  end

  def then_i_see_the_sign_up_form
    expect(teacher_sign_up_page.heading.text).to eq("Your email address")
    expect(teacher_sign_up_page.email_heading).to have_content(
      "Your email address",
    )
    expect(teacher_sign_up_page.hint).to have_content(
      "We’ll use this to send you a link to continue with your QTS application.",
    )
  end

  def then_i_see_the_check_your_email_page
    expect(check_email_page).to have_title("Check your email")
    expect(check_email_page.heading.text).to eq("Check your email")
  end

  def then_i_see_successful_confirmation
    expect(new_application_form_page.heading.text).to eq(
      "In which country are you currently recognised as a teacher?",
    )
  end

  def then_i_see_the_new_application_form
    expect(new_application_form_page.heading.text).to eq(
      "In which country are you currently recognised as a teacher?",
    )
  end

  def then_i_see_the_blank_email_address_message
    expect(page).to have_content("Enter your email address")
  end

  def then_i_see_the_signed_out_page
    expect(signed_out_page.body_content).to have_content(
      "We’ve signed you out of the Apply for qualified teacher status (QTS) service.",
    )
    expect(signed_out_page.body_content).to have_content(
      "We’ve saved the information you’ve added to your application so far.",
    )
  end

  alias_method :and_i_fill_create_teacher_email_address,
               :when_i_fill_create_teacher_email_address

  alias_method :and_i_fill_sign_in_teacher_email_address,
               :when_i_fill_sign_in_teacher_email_address

  def and_i_receive_a_magic_link_email
    message = ActionMailer::Base.deliveries.last
    expect(message).to_not be_nil

    expect(message.subject).to eq("Your QTS application link")
    expect(message.to).to include("test@example.com")
  end

  def and_i_click_continue
    click_button "Continue", visible: false
  end

  def and_i_see_already_confirmed_message
    expect(teacher_sign_up_page).to have_content(
      "Your email address is already confirmed, please sign in.",
    )
  end
end
