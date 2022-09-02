# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Eligibility check", type: :system do
  before do
    given_countries_exist
    given_the_service_is_open
  end

  it "happy path" do
    when_i_visit_the_start_page
    then_i_see_the_start_page

    when_i_press_start_now
    then_i_see_the_country_page

    when_i_select_an_eligible_country
    then_i_see_the_qualifications_page

    when_i_have_a_qualification
    then_i_see_the_degree_page

    when_i_have_a_degree
    then_i_see_the_teach_children_page

    when_i_can_teach_children
    then_i_see_the_misconduct_page

    when_i_dont_have_a_misconduct_record
    then_i_see_the_eligible_page

    when_i_visit_the_start_page
    then_i_see_the_start_page
    when_i_press_start_now
    then_i_have_two_eligibility_checks
  end

  it "ineligible paths" do
    when_i_visit_the_start_page

    when_i_press_start_now
    when_i_select_an_ineligible_country
    then_i_see_the_ineligible_page
    and_i_see_the_ineligible_country_text

    when_i_press_back
    when_i_select_an_eligible_country
    then_i_see_the_qualifications_page

    when_i_dont_have_a_qualification
    then_i_see_the_degree_page

    when_i_dont_have_a_degree
    then_i_see_the_teach_children_page

    when_i_cant_teach_children
    then_i_see_the_misconduct_page

    when_i_have_a_misconduct_record
    then_i_see_the_ineligible_page
    and_i_see_the_ineligible_degree_text
    and_i_see_the_ineligible_qualification_text
    and_i_see_the_ineligible_teach_children_text
    and_i_see_the_ineligible_misconduct_text
  end

  it "trying to skip steps" do
    when_i_visit_the_start_page
    then_i_see_the_start_page

    when_i_try_to_go_to_the_eligible_page
    then_i_see_the_start_page

    when_i_try_to_go_to_the_ineligible_page
    then_i_see_the_start_page

    when_i_press_start_now
    then_i_see_the_country_page

    when_i_try_to_go_to_the_region_page
    then_i_see_the_country_page

    when_i_select_an_eligible_country
    then_i_see_the_qualifications_page

    when_i_try_to_go_to_the_degree_page
    then_i_see_the_qualifications_page

    when_i_have_a_qualification
    then_i_see_the_degree_page

    when_i_try_to_go_to_the_teach_children_page
    then_i_see_the_degree_page

    when_i_have_a_degree
    then_i_see_the_teach_children_page

    when_i_try_to_go_to_the_misconduct_page
    then_i_see_the_teach_children_page

    when_i_can_teach_children
    then_i_see_the_misconduct_page
  end

  it "handles the country picker error" do
    when_i_visit_the_start_page
    when_i_press_start_now
    when_i_dont_select_a_country
    then_i_see_the_country_error_message

    when_i_select_an_eligible_country
    then_i_see_the_qualifications_page
  end

  it "sends legacy users to the old service" do
    when_i_visit_the_start_page
    when_i_press_start_now
    when_i_select_a_legacy_country
    then_i_see_the_eligible_page

    when_i_press_start
    then_i_see_the_legacy_service
  end

  it "handles countries with multiple regions" do
    when_i_visit_the_start_page
    when_i_press_start_now
    when_i_select_a_multiple_region_country
    then_i_see_the_region_page

    when_i_select_a_region
    then_i_see_the_qualifications_page
  end

  it "service is closed" do
    given_the_service_is_closed
    when_i_visit_the_start_page
    then_i_do_not_see_the_start_page

    when_i_am_authorized_as_a_support_user
    given_the_service_is_open
    when_i_visit_the_start_page
    then_i_see_the_start_page

    when_i_press_start_now
    then_i_see_the_country_page

    when_i_select_an_eligible_country
    then_i_see_the_qualifications_page
  end

  it "test user is disabled" do
    given_the_service_is_closed
    when_i_visit_the_start_page
    then_i_do_not_see_the_start_page

    when_i_am_authorized_as_a_test_user
    when_i_visit_the_start_page
    then_i_do_not_see_the_start_page

    given_the_test_user_is_enabled
    when_i_am_authorized_as_a_test_user
    when_i_visit_the_start_page
    then_i_see_the_start_page
  end

  private

  def given_countries_exist
    create(:country, :with_national_region, code: "GB-SCT")
    create(:country, :with_legacy_region, code: "FR")

    it = create(:country, code: "IT")
    create(:region, country: it, name: "Region")
    create(:region, country: it, name: "Other Region")
  end

  def start_page
    @start_page ||= PageObjects::EligibilityInterface::Start.new
  end

  def when_i_visit_the_start_page
    start_page.load
  end

  def then_i_see_the_start_page
    expect(page).to have_title(
      "Apply for qualified teacher status (QTS) in England"
    )
    expect(start_page.heading).to have_content(
      "Check your eligibility to apply for qualified teacher status (QTS) in England"
    )
    expect(start_page.description).to have_content(
      "This service is for qualified teachers who trained outside of England" \
        " who want to apply for qualified teacher status (QTS) to teach in" \
        " English schools."
    )
  end

  def then_i_do_not_see_the_start_page
    expect(start_page).to_not have_start_button
  end

  def when_i_press_start_now
    start_page.start_button.click
  end

  def country_page
    @country_page ||= PageObjects::EligibilityInterface::Country.new
  end

  def when_i_select_a_country(country)
    country_page.form.location_field.fill_in with: country
    country_page.form.continue_button.click
  end

  def when_i_select_an_eligible_country
    when_i_select_a_country "Scotland"
  end

  def when_i_select_an_ineligible_country
    when_i_select_a_country "Spain"
  end

  def when_i_select_a_legacy_country
    when_i_select_a_country "France"
  end

  def when_i_select_a_multiple_region_country
    when_i_select_a_country "Italy"
  end

  def when_i_dont_select_a_country
    country_page.form.continue_button.click
  end

  def then_i_see_the_country_page
    expect(country_page).to have_title(
      "In which country are you currently recognised as a teacher?"
    )
    expect(country_page.heading).to have_content(
      "In which country are you currently recognised as a teacher?"
    )
  end

  def then_i_see_the_country_error_message
    expect(country_page).to have_error_summary
    expect(country_page.error_summary.body).to have_content(
      "Tell us where you’re currently recognised as a teacher"
    )
  end

  def region_page
    @region_page ||= PageObjects::EligibilityInterface::Region.new
  end

  def when_i_try_to_go_to_the_region_page
    region_page.load
  end

  def then_i_see_the_region_page
    expect(region_page).to have_title(
      "In which state/territory are you currently recognised as a teacher?"
    )
    expect(region_page.heading).to have_content(
      "In which state/territory are you currently recognised as a teacher?"
    )
  end

  def when_i_select_a_region
    region_page.form.radio_items.first.input.click
    region_page.form.continue_button.click
  end

  def qualification_page
    @qualification_page ||= PageObjects::EligibilityInterface::Qualification.new
  end

  def when_i_try_to_go_to_the_qualification_page
    qualification_page.load
  end

  def then_i_see_the_qualifications_page
    expect(qualification_page).to have_title(
      "Do you have a teacher training qualification?"
    )
    expect(qualification_page.heading).to have_content(
      "Do you have a teacher training qualification?"
    )
  end

  def when_i_have_a_qualification
    qualification_page.form.yes_radio_item.input.click
    qualification_page.form.continue_button.click
  end

  def when_i_dont_have_a_qualification
    qualification_page.form.no_radio_item.input.click
    qualification_page.form.continue_button.click
  end

  def degree_page
    @degree_page ||= PageObjects::EligibilityInterface::Degree.new
  end

  def when_i_try_to_go_to_the_degree_page
    degree_page.load
  end

  def then_i_see_the_degree_page
    expect(degree_page).to have_title("Do you have a university degree?")
    expect(degree_page.heading).to have_content(
      "Do you have a university degree?"
    )
  end

  def when_i_have_a_degree
    degree_page.form.yes_radio_item.input.click
    degree_page.form.continue_button.click
  end

  def when_i_dont_have_a_degree
    degree_page.form.no_radio_item.input.click
    degree_page.form.continue_button.click
  end

  def teach_children_page
    @teach_children_page ||=
      PageObjects::EligibilityInterface::TeachChildren.new
  end

  def when_i_try_to_go_to_the_teach_children_page
    teach_children_page.load
  end

  def then_i_see_the_teach_children_page
    expect(teach_children_page).to have_title(
      "Are you qualified to teach children who are aged somewhere between 5 and 16 years?"
    )
    expect(teach_children_page.heading).to have_content(
      "Are you qualified to teach children who are aged somewhere between 5 and 16 years?"
    )
  end

  def when_i_can_teach_children
    teach_children_page.form.yes_radio_item.input.click
    teach_children_page.form.continue_button.click
  end

  def when_i_cant_teach_children
    teach_children_page.form.no_radio_item.input.click
    teach_children_page.form.continue_button.click
  end

  def misconduct_page
    @misconduct_page ||= PageObjects::EligibilityInterface::Misconduct.new
  end

  def when_i_try_to_go_to_the_misconduct_page
    misconduct_page.load
  end

  def then_i_see_the_misconduct_page
    expect(misconduct_page).to have_title(
      "Do you have any sanctions or restrictions on your employment record?"
    )
    expect(misconduct_page.heading).to have_content(
      "Do you have any sanctions or restrictions on your employment record?"
    )
  end

  def when_i_have_a_misconduct_record
    misconduct_page.form.yes_radio_item.input.click
    misconduct_page.form.continue_button.click
  end

  def when_i_dont_have_a_misconduct_record
    misconduct_page.form.no_radio_item.input.click
    misconduct_page.form.continue_button.click
  end

  def when_i_press_back
    click_link "Back"
  end

  def when_i_press_start
    click_link "Apply for QTS"
  end

  def when_i_try_to_go_to_the_eligible_page
    visit "/eligibility/eligible"
  end

  def when_i_try_to_go_to_the_ineligible_page
    visit "/eligibility/ineligible"
  end

  def then_i_see_the_eligible_page
    expect(page).to have_content(
      "You’re eligible to apply for qualified teacher status (QTS) in England"
    )
  end

  def then_i_see_the_ineligible_page
    expect(page).to have_content(
      "You’re not eligible to apply for qualified teacher status (QTS) in England"
    )
  end

  def then_i_see_the_legacy_service
    expect(page).to have_current_path("/MutualRecognition/")
  end

  def and_i_see_the_ineligible_country_text
    expect(page).to have_content(
      "You’re not eligible to apply for qualified teacher status (QTS) in England"
    )
    expect(page).to have_content(
      "Teachers applying from Spain are not currently eligible to use this service."
    )
    expect(page).to have_content(
      "You can also learn more about teaching in England."
    )
  end

  def and_i_see_the_ineligible_completed_requirements_text
    expect(page).to have_content(
      "You have not completed all requirements to work as a qualified teacher in Scotland."
    )
  end

  def and_i_see_the_ineligible_misconduct_text
    expect(page).to have_content(
      "To teach in England, you must not have any findings of misconduct or restrictions on your practice."
    )
  end

  def and_i_see_the_ineligible_teach_children_text
    expect(page).to have_content(
      "You are not qualified to teach children who are aged somewhere between 5 and 16 years."
    )
  end

  def and_i_see_the_ineligible_qualification_text
    expect(page).to have_content(
      "You have not completed a formal teacher training course, for example, an undergraduate teaching " \
        "degree or postgraduate teacher training course."
    )
  end

  def and_i_see_the_ineligible_degree_text
    expect(page).to have_content("You do not have a degree.")
  end

  def then_i_have_two_eligibility_checks
    expect(EligibilityCheck.count).to eq(2)
  end
end
