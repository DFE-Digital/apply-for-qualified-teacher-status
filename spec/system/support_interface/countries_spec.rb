# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Countries support", type: :system do
  it "requires permission" do
    given_i_am_authorized_as_an_assessor_user
    when_i_visit_the_countries_page
    then_i_see_the_forbidden_page
  end

  it "does not allow any any access if user is archived" do
    given_i_am_authorized_as_an_archived_support_user
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

    when_i_fill_in_the_edit_country_form
    then_i_see_country_changes_preview
    support_country_preview_page.click_save

    when_i_click_on_a_region
    then_i_see_a_region

    and_i_fill_in_the_edit_region_form
    then_i_see_the_region_preview
    support_region_preview_page.click_save

    when_i_visit_the_countries_page
    then_i_see_the_countries_page
    and_i_see_the_updated_countries
  end

  it "allows creating a new country without regions" do
    given_countries_exist
    given_i_am_authorized_as_a_support_user
    when_i_visit_the_countries_page

    and_i_click_new_country
    then_i_see_the_new_country_page

    then_i_complete_the_new_country_form_without_regions
    then_i_see_the_countries_page
    and_i_see_the_newly_created_country
  end

  it "allows creating a new country with regions" do
    given_countries_exist
    given_i_am_authorized_as_a_support_user
    when_i_visit_the_countries_page

    and_i_click_new_country
    then_i_see_the_new_country_page

    then_i_complete_the_new_country_form_with_regions
    then_i_see_the_countries_page
    and_i_see_the_newly_created_country_with_regions
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
    support_countries_index_page.load
  end

  def then_i_see_the_countries_page
    expect(support_countries_index_page).to be_displayed
    expect(support_countries_index_page).to have_heading
  end

  def and_i_see_the_initial_countries
    expect(support_countries_index_page).to have_country("United States")
    expect(support_countries_index_page).to have_region("Hawaii")
  end

  def and_i_see_the_updated_countries
    expect(support_countries_index_page).to have_country("United States")
    expect(support_countries_index_page).to have_region("California")
  end

  def and_i_see_the_newly_created_country
    expect(support_countries_index_page).to have_country("Afghanistan")
  end

  def and_i_see_the_newly_created_country_with_regions
    expect(support_countries_index_page).to have_country("Afghanistan")
    expect(support_countries_index_page).to have_region("Kabul")
    expect(support_countries_index_page).to have_region("Herat")
  end

  def when_i_click_on_a_country
    support_countries_index_page.click_country("United States")
  end

  def when_i_fill_in_the_edit_country_form
    support_edit_country_page.fill_in_other_information("Other")
    support_edit_country_page.fill_in_sanction_information(
      "Sanction information",
    )
    support_edit_country_page.fill_in_status_information("Status information")
    support_edit_country_page.fill_in_teaching_qualification_information(
      "Qualifications information",
    )
    support_edit_country_page.select_has_regions
    support_edit_country_page.fill_in_region_names("California")
    support_edit_country_page.click_preview
  end

  def then_i_see_a_country
    expect(support_edit_country_page).to be_displayed
    expect(support_edit_country_page).to have_heading("United States")
  end

  def then_i_see_country_changes_preview
    expect(support_country_preview_page).to be_displayed
    expect(page).to have_content("Other")
    expect(page).to have_content("Qualifications information")
    expect(page).to have_content("Sanction information")
    expect(page).to have_content("Status information")
    expect(page).to have_content("Create California")
    expect(page).to have_content("Delete Hawaii")
  end

  def when_i_click_on_a_region
    support_countries_index_page.click_region("California")
  end

  def then_i_see_a_region
    expect(support_edit_region_page).to be_displayed
    expect(support_edit_region_page).to have_heading("California")
  end

  def and_i_fill_in_the_edit_region_form
    support_edit_region_page.select_sanction_check("Online")
    support_edit_region_page.select_status_check("Online")
    support_edit_region_page.fill_in_other_information("Other")
    support_edit_region_page.fill_in_sanction_information(
      "Sanction information",
    )
    support_edit_region_page.fill_in_status_information("Status information")
    support_edit_region_page.fill_in_teaching_authority_address("Address")
    support_edit_region_page.fill_in_teaching_authority_certificate(
      "Certificate",
    )
    support_edit_region_page.fill_in_teaching_authority_emails("Email address")
    support_edit_region_page.fill_in_teaching_authority_name("Name")
    support_edit_region_page.fill_in_teaching_authority_online_checker_url(
      "https://www.example.com/checks",
    )
    support_edit_region_page.fill_in_teaching_authority_websites("Website")
    support_edit_region_page.select_yes_teaching_authority_requires_submission_email
    support_edit_region_page.fill_in_teaching_qualification_information(
      "Qualifications information",
    )
    support_edit_region_page.choose_written_statement_optional
    support_edit_region_page.choose_requires_preliminary_check
    support_edit_region_page.click_preview
  end

  def then_i_see_the_region_preview
    expect(support_region_preview_page).to be_displayed
    expect(page).to have_title("Preview California")
    expect(page).to have_content("You’re eligible to apply")
    expect(page).to have_content("Preparing to apply")
    expect(page).to have_content("Certified translations")

    click_on "Proof of qualifications"
    expect(page).to have_content("Qualifications information")

    click_on "Proof that you’re recognised as a teacher"
    expect(page).to have_content(
      "As your education department or authority has an online register of teachers",
    )
    expect(page).to have_content("Status information")
    expect(page).to have_content("Sanction information")
    expect(page).to have_content("Other")
  end

  def then_i_complete_the_new_country_form_without_regions
    support_new_country_page.fill_in_country_of_recognition("Afghanistan")
    support_new_country_page.select_eligibility_route_standard
    support_new_country_page.select_has_regions_false
    support_new_country_page.click_create
  end

  def then_i_complete_the_new_country_form_with_regions
    support_new_country_page.fill_in_country_of_recognition("Afghanistan")
    support_new_country_page.select_eligibility_route_standard
    support_new_country_page.select_has_regions_true
    support_new_country_page.fill_in_region_names("Kabul\nHerat")
    support_new_country_page.click_create
  end

  def and_i_click_new_country
    support_countries_index_page.add_a_new_country_link.click
  end

  def then_i_see_the_new_country_page
    expect(support_new_country_page).to be_displayed
    expect(support_new_country_page).to have_heading("Create a new country")
  end
end
