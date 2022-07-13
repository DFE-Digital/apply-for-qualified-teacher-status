require "rails_helper"

RSpec.describe "Teacher authentication", type: :system do
  it "allows signing up and signing in" do
    given_the_service_is_open
    given_the_service_is_startable

    when_i_visit_the_sign_up_page
    then_i_see_the_sign_up_form

    when_i_fill_teacher_email_address
    and_i_click_sign_up
    then_i_receive_a_teacher_confirmation_email

    when_i_visit_the_teacher_confirmation_email
    then_i_see_successful_confirmation_message

    given_i_clear_my_session

    when_i_visit_the_sign_in_page
    then_i_see_the_sign_in_form

    when_i_fill_teacher_email_address
    and_i_sign_in
    then_i_receive_a_magic_link_email

    when_i_visit_the_magic_link_email
    then_i_see_successful_magic_link_message

    given_i_clear_my_session

    when_i_visit_the_sign_up_page
    then_i_see_the_sign_up_form

    when_i_fill_teacher_email_address
    and_i_click_sign_up
    then_i_receive_a_magic_link_email

    when_i_visit_the_magic_link_email
    then_i_see_successful_magic_link_message
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

  def then_i_see_the_sign_up_form
    expect(page).to have_current_path("/teacher/sign_up")
    expect(page).to have_title("Sign up")
    expect(page).to have_content("Sign up")
  end

  def then_i_see_the_sign_in_form
    expect(page).to have_current_path("/teacher/sign_in")
    expect(page).to have_title("Log in")
    expect(page).to have_content("Log in")
  end

  def then_i_receive_a_magic_link_email
    message = ActionMailer::Base.deliveries.last
    expect(message).to_not be_nil

    expect(message.subject).to eq("Here's your magic login link")
    expect(message.to).to include("test@example.com")
  end

  def then_i_see_successful_confirmation_message
    expect(page).to have_content(
      "Your email address has been successfully confirmed."
    )
  end

  def then_i_see_successful_magic_link_message
    expect(page).to have_content("Signed in successfully.")
  end

  def and_i_sign_in
    click_button "Log in", visible: false
  end
end
