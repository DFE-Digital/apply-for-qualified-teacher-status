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
  end

  private

  def given_the_service_allows_teacher_applications
    FeatureFlag.activate(:teacher_applications)
  end

  def when_i_click_apply_for_qts
    click_link "Apply for QTS", visible: false
  end

  def then_i_see_the_sign_up_form
    expect(page).to have_current_path("/teacher/sign_up")
    expect(page).to have_title("Sign up")
    expect(page).to have_content("Sign up")
  end

  def then_i_see_the_new_application_page
    expect(page).to have_current_path("/teacher/applications/new")
  end
end
