require "rails_helper"

RSpec.describe "Features support", type: :system do
  it "requires permission" do
    given_i_am_authorized_as_an_assessor_user
    when_i_visit_the_feature_flags_page
    then_i_see_the_forbidden_page
  end

  it "allows activating/deactivating features" do
    given_i_am_authorized_as_a_support_user
    when_i_visit_the_feature_flags_page
    then_i_see_the_feature_flags

    when_i_activate_the_applications_flag
    then_the_applications_flag_is_on

    when_i_deactivate_the_applications_flag
    then_the_applications_flag_is_off
  end

  private

  def then_i_see_the_feature_flags
    expect(page).to have_current_path("/support/features")
    expect(page).to have_title("Features")
    expect(page).to have_content("Features")
  end

  def then_the_applications_flag_is_off
    expect(page).to have_content("Feature “Teacher applications” deactivated")
  end

  def then_the_applications_flag_is_on
    expect(page).to have_content("Feature “Teacher applications” activated")
  end

  def when_i_activate_the_applications_flag
    click_on "Activate Teacher applications"
  end

  def when_i_deactivate_the_applications_flag
    click_on "Deactivate Teacher applications"
  end

  def when_i_visit_the_feature_flags_page
    visit support_interface_feature_flags_path
  end
end
