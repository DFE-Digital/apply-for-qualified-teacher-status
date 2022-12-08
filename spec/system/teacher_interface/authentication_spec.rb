require "rails_helper"

RSpec.describe "Teacher authentication", type: :system do
  before { given_the_service_is_open }

  it "allows signing up and signing in" do
    given_countries_exist

    when_i_visit_the(:teacher_sign_up_page)
    then_i_see_the(:teacher_sign_up_page)

    when_i_sign_up
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_teacher_confirmation_email

    when_i_visit_the_teacher_confirmation_email
    then_i_see_the(:teacher_new_application_page)

    given_i_clear_my_session

    when_i_visit_the(:teacher_sign_in_or_sign_up_page)
    then_i_see_the(:teacher_sign_in_or_sign_up_page)

    when_i_choose_yes_and_sign_in
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_magic_link_email

    when_i_visit_the_magic_link_email
    then_i_see_the(:teacher_new_application_page)

    given_i_clear_my_session

    when_i_visit_the(:teacher_sign_in_page)
    then_i_see_the(:teacher_sign_in_page)

    when_i_sign_in
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_magic_link_email

    given_i_clear_my_session

    when_i_visit_the(:teacher_sign_up_page)
    then_i_see_the(:teacher_sign_up_page)

    when_i_sign_up
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_magic_link_email

    when_i_visit_the_magic_link_email
    then_i_see_the(:teacher_new_application_page)

    when_i_select_a_country

    when_i_click_save_and_sign_out
    then_i_see_the(:teacher_signed_out_page)
  end

  it "sign out with navigation link" do
    when_i_visit_the(:teacher_sign_up_page)
    then_i_see_the(:teacher_sign_up_page)

    when_i_sign_up
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_teacher_confirmation_email

    when_i_visit_the_teacher_confirmation_email

    when_i_click_sign_out
    then_i_see_the(:teacher_signed_out_page)
  end

  it "sign up with invalid email address" do
    when_i_visit_the(:teacher_sign_up_page)
    and_i_click_continue
    then_i_see_the_blank_email_address_message
  end

  it "sign in when unconfirmed" do
    when_i_visit_the(:teacher_sign_in_or_sign_up_page)
    then_i_see_the(:teacher_sign_in_or_sign_up_page)

    when_i_choose_yes_and_sign_in
    then_i_see_the(:teacher_check_email_page)
  end

  it "sign in invalid email" do
    when_i_visit_the(:teacher_sign_up_page)
    then_i_see_the(:teacher_sign_up_page)

    when_i_sign_up
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_teacher_confirmation_email

    when_i_visit_the(:teacher_sign_in_or_sign_up_page)
    then_i_see_the(:teacher_sign_in_or_sign_up_page)

    when_i_choose_yes_and_sign_in
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_teacher_confirmation_email
  end

  it "confirming email twice" do
    when_i_visit_the(:teacher_sign_up_page)
    then_i_see_the(:teacher_sign_up_page)

    when_i_sign_up
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_teacher_confirmation_email

    when_i_visit_the_teacher_confirmation_email
    then_i_see_the(:teacher_new_application_page)

    given_i_clear_my_session

    when_i_visit_the_teacher_confirmation_email
    then_i_see_the(:teacher_sign_in_or_sign_up_page)
    and_i_see_already_confirmed_message
  end

  it "sign in with same token" do
    when_i_visit_the(:teacher_sign_up_page)
    then_i_see_the(:teacher_sign_up_page)
    and_i_sign_up

    given_i_clear_my_session

    when_i_visit_the(:teacher_sign_in_or_sign_up_page)
    then_i_see_the(:teacher_sign_in_or_sign_up_page)

    when_i_choose_yes_and_sign_in
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_magic_link_email

    when_i_visit_the_magic_link_email
    then_i_see_the(:teacher_new_application_page)

    given_i_clear_my_session

    when_i_visit_the_magic_link_email
    then_i_see_the_sign_in_form
  end

  it "signing up with existing email address" do
    when_i_visit_the(:teacher_sign_up_page)
    then_i_see_the(:teacher_sign_up_page)

    when_i_sign_up
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_teacher_confirmation_email

    when_i_visit_the_teacher_confirmation_email
    then_i_see_the(:teacher_new_application_page)

    given_i_clear_my_session

    when_i_visit_the(:teacher_sign_up_page)
    then_i_see_the(:teacher_sign_up_page)

    when_i_sign_up
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_magic_link_email

    when_i_visit_the_magic_link_email
    then_i_see_the(:teacher_new_application_page)
  end

  private

  def given_countries_exist
    create(:country, :with_national_region, code: "GB-SCT")
  end

  def given_i_clear_my_session
    Capybara.reset_sessions!
  end

  def when_i_sign_up
    teacher_sign_up_page.submit(email: "test@example.com")
  end

  def when_i_sign_in
    teacher_sign_in_page.submit(email: "test@example.com")
  end

  def when_i_choose_yes_and_sign_in
    teacher_sign_in_or_sign_up_page.submit_sign_in(email: "test@example.com")
  end

  def when_i_visit_the_magic_link_email
    message = ActionMailer::Base.deliveries.last
    uri = URI.parse(URI.extract(message.body.encoded).first)
    expect(uri.path).to eq("/teacher/magic_link")
    expect(uri.query).to include("token")
    visit "#{uri.path}?#{uri.query}"
  end

  def when_i_select_a_country
    country_page.submit(country: "Scotland")
  end

  def when_i_click_sign_out
    click_link "Sign out"
  end

  def when_i_click_save_and_sign_out
    click_link "Save and sign out"
  end

  def then_i_see_the_blank_email_address_message
    expect(teacher_sign_up_page).to have_content("Enter your email address")
  end

  def and_i_receive_a_magic_link_email
    message = ActionMailer::Base.deliveries.last
    expect(message).to_not be_nil

    expect(message.subject).to eq("Your QTS application link")
    expect(message.to).to include("test@example.com")
  end

  def and_i_see_already_confirmed_message
    expect(teacher_sign_up_page).to have_content(
      "Your email address is already confirmed, please sign in.",
    )
  end
end
