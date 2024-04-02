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
end
