# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor authentication", type: :system do
  it "allows signing in and signing out" do
    given_the_service_is_open
    given_staff_exist

    when_i_visit_the_sign_in_page
    then_i_see_the_sign_in_form

    when_i_fill_in_the_sign_in_form
    and_i_click_continue

    when_i_click_sign_out
    then_i_see_the_sign_in_form
    and_i_see_the_signed_out_message
  end

  private

  def given_staff_exist
    create(:staff, :confirmed, email: "staff@example.com", password: "password")
  end

  def when_i_visit_the_sign_in_page
    visit new_staff_session_path
  end

  def when_i_fill_in_the_sign_in_form
    fill_in "staff-email-field", with: "staff@example.com"
    fill_in "staff-password-field", with: "password"
  end

  def when_i_click_sign_out
    click_link "Sign out"
  end

  def then_i_see_the_sign_in_form
    expect(page).to have_content("Email")
    expect(page).to have_content("Password")
  end

  def and_i_see_the_signed_out_message
    expect(page).to have_content("Signed out successfully.")
  end
end
