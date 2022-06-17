require "rails_helper"

RSpec.describe "Support", type: :system do
  before { given_countries_exist }

  it "using the support interface" do
    when_i_am_authorized_as_a_support_user
    when_i_visit_the_feature_flags_page
    then_i_see_the_feature_flags

    when_i_activate_the_service_open_flag
    then_the_service_open_flag_is_on

    when_i_deactivate_the_service_open_flag
    then_the_service_open_flag_is_off
  end

  private

  def given_countries_exist
    create(:region, :national, country: create(:country, code: "IE"))
    create(:region, :national, country: create(:country, code: "PL"))
    create(:region, name: "Hawaii", country: create(:country, code: "US"))
    create(:region, :national, country: create(:country, code: "ES"))
    create(
      :region,
      name: "British Columbia",
      country: create(:country, code: "CA")
    )
    create(:region, :national, country: create(:country, code: "CY"))
  end

  def then_i_see_the_feature_flags
    expect(page).to have_current_path("/support/features")
    expect(page).to have_title("Features")
    expect(page).to have_content("Features")
  end

  def then_the_service_open_flag_is_off
    expect(page).to have_content("Feature “Service open” deactivated")
    expect(page).to have_content("Service open\n- Inactive")
  end

  def then_the_service_open_flag_is_on
    expect(page).to have_content("Feature “Service open” activated")
    expect(page).to have_content("Service open\n- Active")
  end

  def when_i_activate_the_service_open_flag
    click_on "Activate Service open"
  end

  def when_i_am_authorized_as_a_support_user
    page.driver.basic_authorize(
      ENV.fetch("SUPPORT_USERNAME", "test"),
      ENV.fetch("SUPPORT_PASSWORD", "test")
    )
  end

  def when_i_deactivate_the_service_open_flag
    click_on "Deactivate Service open"
  end

  def when_i_visit_the_feature_flags_page
    visit support_interface_features_path
  end

  def when_i_visit_the_countries_path
    visit support_interface_countries_path
  end

  def then_i_see_the_countries
    expect(page).to have_current_path("/support/countries")
    expect(page).to have_title("Countries")
    expect(page).to have_content("Countries")
  end

  def when_i_configure_the_private_beta_countries
    click_on "Configure private beta countries"
  end

  def then_the_private_beta_countries_are_configured
    expect(page).to have_content("Private beta countries configured")
  end
end
