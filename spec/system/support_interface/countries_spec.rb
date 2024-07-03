# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Countries support", type: :system do
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

    when_i_fill_other_information
    when_i_fill_sanction_information
    when_i_fill_status_information
    when_i_fill_teaching_qualification_information
    when_i_fill_regions
    and_i_click_preview
    then_i_see_country_changes_preview
    then_i_see_region_changes_confirmation
    and_i_click_save

    when_i_click_on_a_region
    then_i_see_a_region

    when_i_select_sanction_check
    when_i_select_status_check
    when_i_fill_other_information
    when_i_fill_sanction_information
    when_i_fill_status_information
    when_i_fill_teaching_authority_address
    when_i_fill_teaching_authority_certificate
    when_i_fill_teaching_authority_emails
    when_i_fill_teaching_authority_name
    when_i_fill_teaching_authority_online_checker_url
    when_i_fill_teaching_authority_websites
    when_i_select_yes_teaching_authority_requires_submission_email
    when_i_fill_teaching_qualification_information
    when_i_check_written_statement_optional
    when_i_check_requires_preliminary_check
    and_i_click_preview
    then_i_see_the_preview
    and_i_click_save

    when_i_visit_the_countries_page
    then_i_see_the_countries_page
    and_i_see_the_updated_countries
  end

  private

  def given_countries_exist
    create(:region, :national, country: create(:country, code: "IE"))
    create(:region, :national, country: create(:country, code: "PL"))
    united_states = create(:country, code: "US")
    create(:region, name: "Hawaii", country: united_states)
    create(:region, name: "New York", country: united_states)
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

  def then_i_see_country_changes_preview
    expect(page).to have_content("Other")
    expect(page).to have_content("Qualifications information")
  end

  def then_i_see_region_changes_confirmation
    expect(page).to have_content("Create California")
    expect(page).to have_content("Delete Hawaii")
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
    choose "support-interface-country-form-has-regions-true-field",
           visible: :all
    fill_in "support-interface-country-form-region-names-field",
            with: "California"
  end

  def when_i_select_sanction_check
    select "Online", from: "support-interface-region-form-sanction-check-field"
  end

  def when_i_select_status_check
    select "Online", from: "support-interface-region-form-status-check-field"
  end

  def when_i_fill_teaching_authority_name
    fill_in "support-interface-region-form-teaching-authority-name-field",
            with: "Name"
  end

  def when_i_fill_teaching_authority_address
    fill_in "support-interface-region-form-teaching-authority-address-field",
            with: "Address"
  end

  def when_i_fill_teaching_authority_emails
    fill_in "support-interface-region-form-teaching-authority-emails-string-field",
            with: "Email address"
  end

  def when_i_fill_teaching_authority_websites
    fill_in "support-interface-region-form-teaching-authority-websites-string-field",
            with: "Website"
  end

  def when_i_fill_other_information
    fill_in "support-interface-region-form-other-information-field",
            with: "Other"
  rescue Capybara::ElementNotFound
    fill_in "support-interface-country-form-other-information-field",
            with: "Other"
  end

  def when_i_fill_teaching_authority_certificate
    fill_in "support-interface-region-form-teaching-authority-certificate-field",
            with: "Certificate"
  end

  def when_i_fill_teaching_authority_online_checker_url
    fill_in "support-interface-region-form-teaching-authority-online-checker-url-field",
            with: "https://www.example.com/checks"
  end

  def when_i_fill_sanction_information
    fill_in "support-interface-region-form-sanction-information-field",
            with: "Sanction information"
  rescue Capybara::ElementNotFound
    fill_in "support-interface-country-form-sanction-information-field",
            with: "Sanction information"
  end

  def when_i_fill_status_information
    fill_in "support-interface-region-form-status-information-field",
            with: "Status information"
  rescue Capybara::ElementNotFound
    fill_in "support-interface-country-form-status-information-field",
            with: "Status information"
  end

  def when_i_select_yes_teaching_authority_requires_submission_email
    choose "support-interface-region-form-teaching-authority-requires-submission-email-true-field",
           visible: :all
  end

  def when_i_fill_teaching_qualification_information
    fill_in "support-interface-region-form-teaching-qualification-information-field",
            with: "Qualifications information"
  rescue Capybara::ElementNotFound
    fill_in "support-interface-country-form-teaching-qualification-information-field",
            with: "Qualifications information"
  end

  def when_i_check_written_statement_optional
    choose "support-interface-region-form-written-statement-optional-true-field",
           visible: false
  end

  def when_i_check_requires_preliminary_check
    choose "support-interface-region-form-requires-preliminary-check-true-field",
           visible: false
  end

  def and_i_click_save
    click_button "Save", visible: false
  end

  def and_i_click_preview
    click_button "Preview", visible: false
  end
end
