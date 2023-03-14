require "rails_helper"

RSpec.describe "Countries support", type: :system do
  before { given_the_service_is_open }

  it "requires permission" do
    given_i_am_authorized_as_an_assessor_user
    when_i_visit_the_countries_page
    then_i_see_the_forbidden_page
  end

  it "allows modifying countries" do
    given_countries_exist
    given_i_am_authorized_as_a_support_user
    when_i_visit_the_countries_page
    then_i_see_the_countries_page
    and_i_see_the_initial_countries

    when_i_click_on_a_country
    then_i_see_a_country

    when_i_fill_teaching_authority_name
    when_i_fill_teaching_authority_address
    when_i_fill_teaching_authority_emails
    when_i_fill_teaching_authority_websites
    when_i_fill_teaching_authority_other
    when_i_fill_teaching_authority_sanction_information
    when_i_fill_teaching_authority_status_information
    when_i_fill_teaching_authority_certificate
    when_i_fill_teaching_authority_online_checker_url
    when_i_fill_teaching_authority_checks_sanctions
    when_i_fill_qualifications_information
    when_i_fill_regions
    and_i_save
    then_i_see_country_contact_preview
    then_i_see_region_changes_confirmation
    and_i_confirm
    and_i_see_a_success_banner

    when_i_click_on_a_region
    then_i_see_a_region

    when_i_select_sanction_check
    when_i_select_status_check
    when_i_fill_teaching_authority_name
    when_i_fill_teaching_authority_address
    when_i_fill_teaching_authority_emails
    when_i_fill_teaching_authority_websites
    when_i_fill_teaching_authority_other
    when_i_fill_teaching_authority_sanction_information
    when_i_fill_teaching_authority_status_information
    when_i_fill_teaching_authority_certificate
    when_i_fill_teaching_authority_online_checker_url
    when_i_check_teaching_authority_requires_submission_email
    when_i_fill_qualifications_information
    when_i_check_written_statement_optional
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
      country: create(:country, code: "CA"),
    )
    create(:region, :national, country: create(:country, code: "CY"))
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

  def then_i_see_country_contact_preview
    expect(page).to have_content("Name")
    expect(page).to have_content("Address")
    expect(page).to have_content("Email address")
    expect(page).to have_content("Website")
    expect(page).to have_content("Certificate")
    expect(page).to have_content("Other")
    expect(page).to have_content("Qualifications information")
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
    expect(page).to have_content("Certified translations")
    click_on "Proof of qualifications"
    expect(page).to have_content("Qualifications information")
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

  def when_i_fill_teaching_authority_name
    fill_in "region-teaching-authority-name-field", with: "Name"
  rescue Capybara::ElementNotFound
    fill_in "country-teaching-authority-name-field", with: "Name"
  end

  def when_i_fill_teaching_authority_address
    fill_in "region-teaching-authority-address-field", with: "Address"
  rescue Capybara::ElementNotFound
    fill_in "country-teaching-authority-address-field", with: "Address"
  end

  def when_i_fill_teaching_authority_emails
    fill_in "region-teaching-authority-emails-string-field",
            with: "Email address"
  rescue Capybara::ElementNotFound
    fill_in "country-teaching-authority-emails-string-field",
            with: "Email address"
  end

  def when_i_fill_teaching_authority_websites
    fill_in "region-teaching-authority-websites-string-field", with: "Website"
  rescue Capybara::ElementNotFound
    fill_in "country-teaching-authority-websites-string-field", with: "Website"
  end

  def when_i_fill_teaching_authority_other
    fill_in "region-teaching-authority-other-field", with: "Other"
  rescue Capybara::ElementNotFound
    fill_in "country-teaching-authority-other-field", with: "Other"
  end

  def when_i_fill_teaching_authority_certificate
    fill_in "region-teaching-authority-certificate-field", with: "Certificate"
  rescue Capybara::ElementNotFound
    fill_in "country-teaching-authority-certificate-field", with: "Certificate"
  end

  def when_i_fill_teaching_authority_online_checker_url
    fill_in "region-teaching-authority-online-checker-url-field",
            with: "https://www.example.com/checks"
  rescue Capybara::ElementNotFound
    fill_in "country-teaching-authority-online-checker-url-field",
            with: "https://www.example.com/checks"
  end

  def when_i_fill_teaching_authority_checks_sanctions
    check "country-teaching-authority-checks-sanctions-1-field", visible: false
  end

  def when_i_fill_teaching_authority_sanction_information
    fill_in "region-teaching-authority-sanction-information-field",
            with: "Sanction information"
  rescue Capybara::ElementNotFound
    fill_in "country-teaching-authority-sanction-information-field",
            with: "Sanction information"
  end

  def when_i_fill_teaching_authority_status_information
    fill_in "region-teaching-authority-status-information-field",
            with: "Status information"
  rescue Capybara::ElementNotFound
    fill_in "country-teaching-authority-status-information-field",
            with: "Status information"
  end

  def when_i_check_teaching_authority_requires_submission_email
    check "region-teaching-authority-requires-submission-email-1-field",
          visible: false
  end

  def when_i_fill_qualifications_information
    fill_in "region-qualifications-information-field",
            with: "Qualifications information"
  rescue Capybara::ElementNotFound
    fill_in "country-qualifications-information-field",
            with: "Qualifications information"
  end

  def when_i_check_written_statement_optional
    check "region-written-statement-optional-1-field", visible: false
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
