require "rails_helper"

RSpec.describe "Teacher authentication", type: :system do
  before do
    given_the_service_is_open
    given_the_service_is_startable
  end

  it "allows signing up and signing in" do
    when_i_visit_the_sign_up_page
    then_i_see_the_sign_up_form

    when_i_fill_teacher_email_address
    and_i_click_continue
    then_i_see_the_check_your_email_page
    and_i_receive_a_teacher_confirmation_email

    when_i_visit_the_teacher_confirmation_email
    then_i_see_successful_confirmation_message

    given_i_clear_my_session

    when_i_visit_the_sign_in_page
    then_i_see_the_sign_in_form

    when_i_choose_yes_sign_in
    and_i_fill_teacher_email_address
    and_i_click_continue
    then_i_see_the_check_your_email_page
    and_i_receive_a_magic_link_email

    when_i_visit_the_magic_link_email
    then_i_see_successful_magic_link_message

    given_i_clear_my_session

    when_i_visit_the_sign_up_page
    then_i_see_the_sign_up_form

    when_i_fill_teacher_email_address
    and_i_click_continue
    then_i_see_the_check_your_email_page
    and_i_receive_a_magic_link_email

    when_i_visit_the_magic_link_email
    then_i_see_successful_magic_link_message
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
    expect(uri.query).to include("teacher")
    visit "#{uri.path}?#{uri.query}"
  end

  def when_i_choose_yes_sign_in
    choose "Yes, sign in", visible: false
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

  def then_i_see_successful_confirmation_message
    expect(page).to have_content(
      "Your email address has been successfully confirmed."
    )
  end

  def then_i_see_successful_magic_link_message
    expect(page).to have_content("Signed in successfully.")
  end

  def then_i_see_the_blank_email_address_message
    expect(page).to have_content("Enter your email address")
  end

  alias_method :and_i_fill_teacher_email_address,
               :when_i_fill_teacher_email_address

  def and_i_receive_a_magic_link_email
    message = ActionMailer::Base.deliveries.last
    expect(message).to_not be_nil

    expect(message.subject).to eq("Here's your magic login link")
    expect(message.to).to include("test@example.com")
  end
end
