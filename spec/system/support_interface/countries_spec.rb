require "rails_helper"

RSpec.describe "Countries support", type: :system do
  it "allows modifying countries" do
    given_countries_exist

    when_i_am_authorized_as_a_support_user
    when_i_visit_the_countries_page
    then_i_see_the_countries_page
    and_i_see_the_initial_countries

    when_i_click_on_a_country
    then_i_see_a_country

    when_i_fill_regions
    and_i_save
    then_i_see_region_changes_confirmation
    and_i_confirm
    and_i_see_a_success_banner

    when_i_click_on_a_region
    then_i_see_a_region

    when_i_select_sanction_check
    when_i_select_status_check
    when_i_fill_teaching_authority_address
    when_i_fill_teaching_authority_certificate
    when_i_fill_teaching_authority_email_address
    when_i_fill_teaching_authority_website
    when_i_fill_teaching_authority_other
    and_i_save_and_preview
    then_i_see_the_preview
    and_i_see_a_success_banner

    when_i_visit_the_countries_page
    then_i_see_the_countries_page
    and_i_see_the_updated_countries
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

  def when_i_am_authorized_as_a_support_user
    page.driver.basic_authorize(
      ENV.fetch("SUPPORT_USERNAME", "test"),
      ENV.fetch("SUPPORT_PASSWORD", "test")
    )
  end

  def when_i_visit_the_countries_page
    visit support_interface_countries_path
  end

  def then_i_see_the_countries_page
    expect(page).to have_current_path("/support/countries")
    expect(page).to have_title("Countries")
    expect(page).to have_content("Countries")
  end

  def and_i_see_the_initial_countries
    expect(page).to have_content("United States")
    expect(page).to have_content("Hawaii")
  end

  def and_i_see_the_updated_countries
    expect(page).to have_content("United States")
    expect(page).to have_content("California")
  end

  def when_i_click_on_a_country
    click_link "United States"
  end

  def then_i_see_a_country
    expect(page).to have_title("United States")
  end

  def then_i_see_region_changes_confirmation
    expect(page).to have_content("CREATE California")
    expect(page).to have_content("DELETE Hawaii")
  end

  def when_i_click_on_a_region
    click_link "California"
  end

  def then_i_see_a_region
    expect(page).to have_title("California")
  end

  def then_i_see_the_preview
    expect(page).to have_title("Preview California")
    expect(page).to have_content("You’re eligible to apply")
    expect(page).to have_content("Preparing to apply")
    expect(page).to have_content("You might need to provide translations")
  end

  def when_i_fill_regions
    fill_in "country-all-regions-field", with: "California"
  end

  def when_i_select_sanction_check
    select "Online", from: "region-sanction-check-field"
  end

  def when_i_select_status_check
    select "Online", from: "region-status-check-field"
  end

  def when_i_fill_teaching_authority_address
    fill_in "region-teaching-authority-address-field", with: "Address"
  end

  def when_i_fill_teaching_authority_certificate
    fill_in "region-teaching-authority-certificate-field", with: "Certificate"
  end

  def when_i_fill_teaching_authority_email_address
    fill_in "region-teaching-authority-email-address-field",
            with: "Email address"
  end

  def when_i_fill_teaching_authority_website
    fill_in "region-teaching-authority-website-field", with: "Website"
  end

  def when_i_fill_teaching_authority_other
    fill_in "region-teaching-authority-other-field", with: "Other"
  end

  def and_i_save
    click_button "Save", visible: false
  end

  def and_i_save_and_preview
    click_button "Save and preview", visible: false
  end

  def and_i_confirm
    click_button "Confirm", visible: false
  end

  def and_i_see_a_success_banner
    expect(page).to have_content "Successfully updated"
  end
end
