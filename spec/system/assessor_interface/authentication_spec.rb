# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Assessor authentication", type: :system do
  it "allows signing in and signing out" do
    given_staff_exist

    when_i_visit_the(:assessor_applications_page)
    then_i_see_the(:assessor_login_page)

    when_i_login
    then_i_see_the(:assessor_applications_page)

    when_i_click_sign_out
    then_i_see_the(:staff_signed_out_page)
  end

  it "does not allow any access if user is archived" do
    given_i_am_authorized_as_an_archived_assessor_user

    when_i_visit_the(:assessor_applications_page)
    then_i_see_the_forbidden_page
  end

  it "has a manage access link" do
    given_staff_exist

    when_i_visit_the(:assessor_applications_page)
    when_i_login
    then_i_see_the_manage_access_link
  end

  private

  def given_staff_exist
    create(:staff, email: "staff@example.com", password: "password")
  end

  def when_i_login
    assessor_login_page.submit(email: "staff@example.com", password: "password")
  end

  def when_i_click_sign_out
    assessor_applications_page.header.sign_out_link.click
  end

  def then_i_see_the_manage_access_link
    expect(assessor_applications_page).to have_content("Manage access")
  end
end
