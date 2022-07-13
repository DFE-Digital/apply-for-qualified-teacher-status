require "rails_helper"

RSpec.describe "Teacher application", type: :system do
  it "allows making an application" do
    given_the_service_is_open
    given_the_service_is_startable
    given_the_service_allows_teacher_applications

    when_i_visit_the_new_application_page
    then_i_see_the_sign_up_form
  end

  private

  def given_the_service_allows_teacher_applications
    FeatureFlag.activate(:teacher_applications)
  end

  def when_i_visit_the_new_application_page
    visit new_teacher_interface_application_form_path
  end

  def then_i_see_the_sign_up_form
    expect(page).to have_current_path("/teacher/sign_up")
    expect(page).to have_title("Sign up")
    expect(page).to have_content("Sign up")
  end
end
