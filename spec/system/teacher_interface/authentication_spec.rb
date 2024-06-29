require "rails_helper"

RSpec.describe "Teacher authentication", type: :system do
  it "allows signing up and signing in" do
    given_countries_exist

    when_i_visit_the(:teacher_sign_up_page)
    then_i_see_the(:teacher_sign_up_page)

    when_i_sign_up
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_teacher_magic_link_email

    when_i_sign_in_using_magic_link
    then_i_see_the(:teacher_new_application_page)

    given_i_clear_my_session

    when_i_visit_the(:teacher_sign_in_or_sign_up_page)
    then_i_see_the(:teacher_sign_in_or_sign_up_page)

    when_i_choose_yes_and_sign_in
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_teacher_magic_link_email

    when_i_sign_in_using_magic_link
    then_i_see_the(:teacher_new_application_page)

    given_i_clear_my_session

    when_i_visit_the(:teacher_sign_in_page)
    then_i_see_the(:teacher_sign_in_page)

    when_i_sign_in
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_teacher_magic_link_email

    given_i_clear_my_session

    when_i_visit_the(:teacher_sign_up_page)
    then_i_see_the(:teacher_sign_up_page)

    when_i_sign_up
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_teacher_magic_link_email

    when_i_sign_in_using_magic_link
    then_i_see_the(:teacher_new_application_page)

    when_i_select_a_country

    when_i_click_save_and_sign_out
    then_i_see_the(:teacher_signed_out_page)
  end

  it "allows signing up and signing in with case insensitive" do
    given_countries_exist

    when_i_visit_the(:teacher_sign_up_page)
    then_i_see_the(:teacher_sign_up_page)

    when_i_sign_up
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_teacher_magic_link_email

    given_i_clear_my_session

    when_i_visit_the(:teacher_sign_in_page)
    then_i_see_the(:teacher_sign_in_page)

    when_i_sign_in_with_different_case
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_teacher_magic_link_email
    and_only_one_teacher_exists
  end

  it "sign out with navigation link" do
    when_i_visit_the(:teacher_sign_up_page)
    then_i_see_the(:teacher_sign_up_page)

    when_i_sign_up
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_teacher_magic_link_email

    when_i_sign_in_using_magic_link

    when_i_click_sign_out
    then_i_see_the(:teacher_signed_out_page)
  end

  it "sign up with invalid email address" do
    when_i_visit_the(:teacher_sign_up_page)
    and_i_click_continue
    then_i_see_the_blank_email_address_message
  end

  it "sign in invalid email" do
    when_i_visit_the(:teacher_sign_up_page)
    then_i_see_the(:teacher_sign_up_page)

    when_i_sign_up
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_teacher_magic_link_email

    when_i_visit_the(:teacher_sign_in_or_sign_up_page)
    then_i_see_the(:teacher_sign_in_or_sign_up_page)

    when_i_choose_yes_and_sign_in
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_teacher_magic_link_email
  end

  it "signing up with existing email address" do
    when_i_visit_the(:teacher_sign_up_page)
    then_i_see_the(:teacher_sign_up_page)

    when_i_sign_up
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_teacher_magic_link_email

    when_i_sign_in_using_magic_link
    then_i_see_the(:teacher_new_application_page)

    given_i_clear_my_session

    when_i_visit_the(:teacher_sign_up_page)
    then_i_see_the(:teacher_sign_up_page)

    when_i_sign_up
    then_i_see_the(:teacher_check_email_page)
    and_i_receive_a_teacher_magic_link_email

    when_i_sign_in_using_magic_link
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

  def and_i_receive_a_teacher_magic_link_email
    message = ActionMailer::Base.deliveries.last
    expect(message).not_to be_nil

    expect(message.subject).to eq(
      "Confirm your email: apply for qualified teacher status (QTS)",
    )
    expect(message.to).to include("test@example.com")

    email_body = message.body.raw_source
    teacher = Teacher.find_by(email: "test@example.com")
    if teacher.sign_in_count == 0
      expect(email_body).to include(
        "Thank you for your interest in applying for qualified teacher status (QTS) in England.",
      )
      expect(email_body).not_to include(
        "Welcome back to apply for qualified teacher status (QTS) in England.",
      )
    else
      expect(email_body).to include(
        "Welcome back to apply for qualified teacher status (QTS) in England.",
      )
      expect(email_body).not_to include(
        "Thank you for your interest in applying for qualified teacher status (QTS) in England.",
      )
    end
  end

  def when_i_sign_in_using_magic_link
    message = ActionMailer::Base.deliveries.last
    link_line = message.body.raw_source.lines.fifth.chomp
    url = link_line.match(/\((http[^)]+)\)/)[1]
    uri = URI.parse(url)
    expect(uri.path).to eq("/teacher/magic_link")
    expect(uri.query).to include("token")
    visit "#{uri.path}?#{uri.query}"

    then_i_see_the(:teacher_magic_link_page)
    teacher_magic_link_page.sign_in
  end

  def when_i_sign_in_with_different_case
    teacher_sign_in_page.submit(email: "TEST@example.com")
  end

  def when_i_choose_yes_and_sign_in
    teacher_sign_in_or_sign_up_page.submit_sign_in(email: "test@example.com")
  end

  def when_i_select_a_country
    eligibility_country_page.submit(country: "Scotland")
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

  def and_i_see_already_confirmed_message
    expect(teacher_sign_up_page).to have_content(
      "Your email address is already confirmed, please sign in.",
    )
  end

  def and_only_one_teacher_exists
    expect(Teacher.count).to eq(1)
  end
end
